function VipdSpawnNPC(Class, Position, Angles, Health, Equipment, Team)
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
    if(NPCData and NPCData.Model) then
        NPC:SetModel(NPCData.Model)
    end
    if(NPCData and NPCData.Material) then
        NPC:SetMaterial(NPCData.Material)
    end
    local SpawnFlags = bit.bor(SF_NPC_FADE_CORPSE, SF_NPC_ALWAYSTHINK)
    if(NPCData and NPCData.SpawnFlags) then SpawnFlags = bit.bor(SpawnFlags, NPCData.SpawnFlags) end
    if(NPCData and NPCData.TotalSpawnFlags) then SpawnFlags = NPCData.TotalSpawnFlags end
    NPC:SetKeyValue("spawnflags", SpawnFlags)
    if(NPCData and NPCData.KeyValues) then
        for k, v in pairs(NPCData.KeyValues) do
            NPC:SetKeyValue(k, v)
        end
    end
    if(NPCData and NPCData.Skin) then
        NPC:SetSkin(NPCData.Skin)
    end
    if( Equipment and Equipment ~= "none" ) then
        NPC:SetKeyValue("additionalequipment", Equipment)
        NPC.Equipment = Equipment
        vTRACE("Gave "..Class.." a "..Equipment)
    end
    if( Team ) then
        NPC:SetKeyValue("SquadName", Team)
    end
    NPC:Spawn()
    NPC:Activate()
    if Health > 0 then
        NPC:SetMaxHealth(Health)
        NPC:SetHealth(Health)
    end
    return NPC
end

-- There is lots of redundancy in setting the relationships, but that's because sometimes it doesn't seem to work.
local function SetEnemyRelationships(NPC)
    local squad = NPC:GetKeyValues()["squadname"]
    for key, ent in pairs(ents.GetAll()) do
        if ent.isFriendly or ent.isEnemy then
            local entSquad = ent:GetKeyValues()["squadname"]
            local entClass = ent:GetClass()
            if squad == entSquad then
                NPC:AddEntityRelationship(ent, D_LI, 99)
                NPC:AddRelationship(entClass.." D_LI 99")
                ent:AddEntityRelationship(NPC, D_LI, 99)
                ent:AddRelationship(NPC:GetClass().." D_LI 99")
            else
                local hate = 90
                if ent.isFriendly then hate = 95 end
                NPC:AddEntityRelationship(ent, D_HT, hate)
                NPC:AddRelationship(entClass.." D_HT "..hate)
            end
        end
    end
    NPC:AddRelationship("player D_HT 98")
    for k, ply in pairs(player.GetAll()) do
        NPC:AddEntityRelationship(ply, D_HT, 99)
    end
end

local function SetCitizenRelationships(NPC)
    for key, ent in pairs(ents.GetAll()) do
        if ent.isEnemy then
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

local function SpawnCitizen(node)
    local Team = VipdFriendlyTeam
    local Position = node.pos
    local Weapon = "none"
    local Angles = Angle(0, 0, 0)
    local Class = "npc_citizen"
    local NPC = VipdSpawnNPC(Class, Position, Angles, 0, Weapon, Team)
    NPC.isFriendly = true
    SetCitizenRelationships(NPC)
    return NPC
end

function GetWeapon(Class, MaxWeaponValue)
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
    elseif(NPCData and NPCData.Weapons) then
        return false
    end
    return Weapon
end

local function ChooseNPC(possibleNpcs)
    --25% chance of forcing the highest value NPC
    local cNPC = possibleNpcs[math.random(#possibleNpcs)]
    local cValue = GetPointValue(cNPC.Class, 1, cNPC.Weapon)
    local percent = math.random(100)
    if percent <= 20 then
        --TODO: Add npc unique percent? Antlion guards spawn too often.
        for k, pNPC in pairs(possibleNpcs) do
            local pValue = GetPointValue(pNPC.Class, 1, pNPC.Weapon)
            if pValue > cValue then
                cValue = pValue
                cNPC = pNPC
            end
        end
    end
    vDEBUG("Chose "..cNPC.Class.." with a "..cNPC.Weapon.." worth "..cValue)
    return cNPC
end

local function SpawnEnemy(node)
    local Team = node.team
    local Position = node.pos
    local Offset = node.offset[1] or 32
    Position = Position + Vector(0,0,1) * Offset
    local maxValue = GetMaxEnemyValue()
    local possible_npcs = { }
    local weapon = "none"
    local team_min_class = { }
    for npc_class, npc in pairs(vipd_npcs) do
        if npc.team == Team then
            if not team_min_class.value or npc.value < team_min_class.value then
                team_min_class.Class = npc_class
                team_min_class.value = npc.value
            end
            if npc.value <= maxValue then
                local weaponValue = maxValue - npc.value
                weapon = GetWeapon(npc_class, weaponValue)
                local pNPC = { }
                pNPC.Class = npc_class
                pNPC.Weapon = weapon
                local validForNode = (node.type == 2 and not npc.flying) or (node.type == 3 and npc.flying)
                if weapon and validForNode then table.insert(possible_npcs, pNPC) end
            end
        end
    end
    if #possible_npcs == 0 then
        team_min_class.Weapon = GetWeapon(team_min_class.Class, 0)
        table.insert(possible_npcs, team_min_class)
    end
    if #possible_npcs > 0 then
        vTRACE(tostring(#possible_npcs).." possible Npcs for team "..Team..".")
        local Angles = Angle(0, 0, 0)
        local cNPC = ChooseNPC(possible_npcs)
        local NPC = VipdSpawnNPC(cNPC.Class, Position, Angles, 0, cNPC.Weapon, Team)
        NPC.isEnemy = true
        SetEnemyRelationships(NPC)

        return NPC
    else
        vWARN("No valid NPC found for Node type: "..node.type)
    end
end

function SpawnNpc(node)
    if node.team == VipdFriendlyTeam then return SpawnCitizen(node) end
    return SpawnEnemy(node)
end