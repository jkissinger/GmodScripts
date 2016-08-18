local function VipdSpawnNPC(Class, Position, Angles, Health, Equipment, Team)
    vDEBUG("Spawning: " .. Class.." with "..Health.." health and a " .. Equipment.. " at "..tostring(Position))
    local NPCList = list.Get("NPC")
    local NPCData = NPCList[Class]
    if NPCData then
        NPC = ents.Create(NPCData.Class)
    else
        NPC = ents.Create(Class)
    end
    NPC:SetPos(Position)
    NPC:SetAngles(Angles)
    if NPCData and NPCData.Model then
        NPC:SetModel(NPCData.Model)
    end
    if NPCData and NPCData.Material then
        NPC:SetMaterial(NPCData.Material)
    end
    local SpawnFlags = bit.bor(SF_NPC_FADE_CORPSE, SF_NPC_ALWAYSTHINK)
    if NPCData and NPCData.SpawnFlags then SpawnFlags = bit.bor(SpawnFlags, NPCData.SpawnFlags) end
    if NPCData and NPCData.TotalSpawnFlags then SpawnFlags = NPCData.TotalSpawnFlags end
    NPC:SetKeyValue("spawnflags", SpawnFlags)
    if NPCData and NPCData.KeyValues then
        for k, v in pairs(NPCData.KeyValues) do
            NPC:SetKeyValue(k, v)
        end
    end
    if NPCData and NPCData.Skin then
        NPC:SetSkin(NPCData.Skin)
    end
    if Equipment and Equipment ~= "none" then
        NPC:SetKeyValue("additionalequipment", Equipment)
        NPC.Equipment = Equipment
        vTRACE("Gave "..Class.." a "..Equipment)
    end
    if Team and Team.name then
        NPC:SetKeyValue("SquadName", Team.name)
    end
    NPC:Spawn()
    NPC:Activate()
    if Health > 0 then
        NPC:SetMaxHealth(Health)
        NPC:SetHealth(Health)
    end
    NPC.VipdName = Class
    NPC:SetKeyValue("vipdname", Class)
    return NPC
end

-- There is lots of redundancy in setting the relationships, but that's because sometimes it doesn't seem to work.
local function SetEnemyRelationships(NPC)
    local squad = NPC:GetKeyValues()["squadname"]
    for key, ent in pairs(ents.GetAll()) do
        if ent.team then
            local entSquad = ent:GetKeyValues()["squadname"]
            local entClass = ent:GetClass()
            if squad == entSquad then
                if NPC.AddEntityRelationship ~= nil then NPC:AddEntityRelationship(ent, D_LI, 99) end
                if NPC.AddRelationship ~= nil then NPC:AddRelationship(entClass.." D_LI 99") end
                if ent.AddEntityRelationship ~= nil then ent:AddEntityRelationship(NPC, D_LI, 99) end
                if ent.AddRelationship ~= nil then ent:AddRelationship(NPC:GetClass().." D_LI 99") end
            else
                local hate = 90
                if IsAlly(ent) then hate = 95 end
                --if NPC.AddEntityRelationship ~= nil then NPC:AddEntityRelationship(ent, D_HT, hate) end
                if NPC.AddRelationship ~= nil then NPC:AddRelationship(entClass.." D_HT "..hate) end
            end
        end
    end
    if NPC.AddRelationship ~= nil then NPC:AddRelationship("player D_HT 98") end
    for k, ply in pairs(player.GetAll()) do
        if NPC.AddEntityRelationship ~= nil then NPC:AddEntityRelationship(ply, D_HT, 99) end
    end
end

local function SetCitizenRelationships(NPC)
    for key, ent in pairs(ents.GetAll()) do
        if IsEnemy(ent) then
            NPC:AddEntityRelationship(ent, D_FR, 95)
            NPC:AddRelationship(ent:GetClass().." D_FR 95")
            ent:AddEntityRelationship(NPC, D_HT, 99)
            ent:AddRelationship(NPC:GetClass().." D_HT 99")
        end
    end
    NPC:AddRelationship("player D_LI 98")
    for k, ply in pairs(player.GetAll()) do
        NPC:AddEntityRelationship(ply, D_LI, 99)
    end
end

local function GetRandomNpcByTeam(team)
    local team_members = GetNpcListByTeam(team)
    vDEBUG("Getting random NPC for team ".. team.name.. " which has " .. #team_members .. " members.")
    return team_members[math.random(#team_members)]
end

local function GetWeapon(Class, MaxWeaponValue)
    local NPCList = list.Get("NPC")
    local NPCData = NPCList[Class]
    local Weapon = "none"
    local pWeapons = { }
    local min_weapon_value = nil
    local min_weapon = nil
    if(NPCData and NPCData.Weapons) then
        for k, weapon_class in pairs(NPCData.Weapons) do
            local vipd_weapon = vipd_weapons[weapon_class]
            if not vipd_weapon then
                vWARN(weapon_class.." is not defined in the config, but "..Class.." uses it!")
            else
                local weapon_value = vipd_weapons[weapon_class].npcValue
                if not min_weapon or weapon_value < min_weapon_value then
                    min_weapon_value = weapon_value
                    min_weapon = weapon_class
                end
                if weapon_value <= MaxWeaponValue then
                    table.insert(pWeapons, weapon_class)
                end
            end
        end
    end
    if #pWeapons == 0 then
        table.insert(pWeapons, min_weapon)
    end
    if #pWeapons > 0 then
        Weapon = pWeapons[math.random(#pWeapons)]
        vTRACE("Chose weapon "..Weapon.." for "..Class)
    end
    return Weapon
end

local function SpawnAlly(node)
    local Team = node.team
    local chance = math.random(100)
    if chance <= VIPD_VIP_CHANCE then
        Team = VipdVipTeam
    end
    local Class = GetRandomNpcByTeam(Team).gmod_class
    local Position = node.pos
    local Angles = Angle(0, 0, 0)
    local Health = Team.health
    local Weapon = "none"
    if Team.name == VipdVipTeam.name then Weapon = GetWeapon(Class, 1000) end
    local NPC = VipdSpawnNPC(Class, Position, Angles, Health, Weapon, Team)
    NPC.team = Team
    SetCitizenRelationships(NPC)
    return NPC
end

local function ChooseNPC(possibleNpcs)
    local cNPC = possibleNpcs[math.random(#possibleNpcs)]
    local percent = math.random(100)
    --20% chance of forcing the highest value NPC
    if percent <= 20 then
        --TODO: Add npc unique percent? Antlion guards spawn too often.
        for k, pNPC in pairs(possibleNpcs) do
            if pNPC.Value > cNPC.Value then
                cNPC = pNPC
            end
        end
    end
    return cNPC
end

local function SpawnEnemy(node)
    local Team = node.team
    local Position = node.pos
    local Offset = node.offset[1] or 32
    Position = Position + Vector(0,0,1) * Offset
    local air_node = node.type == 3
    local maxValue = CalculateMaxEnemyValue()
    local possible_npcs = { }
    local weapon = "none"
    for key, npc in pairs(GetNpcListByTeam(Team)) do
        if npc.value <= maxValue then
            local weapon_value = maxValue - npc.value
            weapon = GetWeapon(npc.gmod_class, weapon_value)
            local pNPC = { }
            pNPC.Class = npc.gmod_class
            if not pNPC.Class then vWARN(npc.name .. " has no class!") end
            pNPC.Weapon = weapon
            local weapon_value = vipd_weapons[weapon].npcValue
            pNPC.Value = npc.value + weapon_value
            local validForNode = (node.type == 2 and not npc.flying) or (node.type == 3 and npc.flying)
            if weapon and validForNode then table.insert(possible_npcs, pNPC) end
        end
    end
    if #possible_npcs > 0 then
        vTRACE(tostring(#possible_npcs).." possible NPCs for team "..Team.name..".")
        local Angles = Angle(0, 0, 0)
        local cNPC = ChooseNPC(possible_npcs)
        local NPC = VipdSpawnNPC(cNPC.Class, Position, Angles, 0, cNPC.Weapon, Team)
        NPC.team = Team
        SetEnemyRelationships(NPC)
        return NPC
    else
        vWARN("No valid NPC found for Node type: "..node.type.." and Team: "..Team.name)
    end
end

function SpawnNpc(node)
    if node.team.name == VipdAllyTeam.name then
        return SpawnAlly(node)
    else
        return SpawnEnemy(node)
    end
end
