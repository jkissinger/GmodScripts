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
    if (NPCData and NPCData.Model) then
        NPC:SetModel(NPCData.Model)
    end
    if (NPCData and NPCData.Material) then
        NPC:SetMaterial(NPCData.Material)
    end
    local SpawnFlags = bit.bor(SF_NPC_FADE_CORPSE, SF_NPC_ALWAYSTHINK)
    if (NPCData and NPCData.SpawnFlags) then SpawnFlags = bit.bor(SpawnFlags, NPCData.SpawnFlags) end
    if (NPCData and NPCData.TotalSpawnFlags) then SpawnFlags = NPCData.TotalSpawnFlags end
    NPC:SetKeyValue("spawnflags", SpawnFlags)
    if (NPCData and NPCData.KeyValues) then
        for k, v in pairs(NPCData.KeyValues) do
            NPC:SetKeyValue(k, v)
        end
    end
    if (NPCData and NPCData.Skin) then
        NPC:SetSkin(NPCData.Skin)
    end
    if ( Equipment and Equipment ~= "none" ) then
        NPC:SetKeyValue("additionalequipment", Equipment)
        NPC.Equipment = Equipment
        vTRACE("Gave "..Class.." a "..Equipment)
    end
    if ( Team ) then
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

function GetWeapon(Class, maxWeaponValue)
    local NPCList = list.Get("NPC")
    local NPCData = NPCList[Class]
    local Weapon = "none"
    local pWeapons = { }
    if (NPCData and NPCData.Weapons) then
        for k, weaponClass in pairs(NPCData.Weapons) do
            local vipd_weapon = vipd_weapons[weaponClass]
            if not vipd_weapon then
                vWARN(weaponClass.." is not defined in the config, but "..Class.." uses it!")
            else
                local weaponValue = vipd_weapons[weaponClass].npcValue
                if weaponValue <= maxWeaponValue then
                    table.insert(pWeapons, weaponClass)
                end
            end
        end
    end
    if #pWeapons > 0 then
        Weapon = pWeapons[math.random(#pWeapons)]
        vTRACE("Chose weapon "..Weapon.." for "..Class)
    elseif (NPCData and NPCData.Weapons) then
        return false
    end
    return Weapon
end

local function ChooseNPC(possibleNpcs)
    --25% chance of forcing the highest value NPC
    local cNPC = possibleNpcs[math.random(#possibleNpcs)]
    local cValue = GetPointValue(cNPC.Class, 1, cNPC.Weapon)
    local percent = math.random(100)
    if percent <= 25 then
        --TODO: Add npc unique percent? Antlion guards spawn too often.
        for k, pNPC in pairs(possibleNpcs) do
            local pValue = GetPointValue(pNPC.Class, 1, pNPC.Weapon)
            if pValue > cValue then
                cValue = pValue
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
    local maxValue = GetMaxEnemyValue()
    local possibleNpcs = { }
    local Weapon = "none"
    for Class, npc in pairs(vipd_npcs) do
        if npc.value <= maxValue and npc.team == Team then
            local weaponValue = maxValue - npc.value
            Weapon = GetWeapon(Class, weaponValue)
            local pNPC = { }
            pNPC.Class = Class
            pNPC.Weapon = Weapon
            local validForNode = (node.type == 2 and not npc.flying) or (node.type == 3 and npc.flying)
            if Weapon and validForNode then table.insert(possibleNpcs, pNPC) end
        end
    end
    if #possibleNpcs > 0 then
        local Angles = Angle(0, 0, 0)
        local cNPC = ChooseNPC(possibleNpcs)
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