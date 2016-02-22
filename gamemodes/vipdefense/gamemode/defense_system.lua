function InitAdventureSystem()
    MsgCenter("Initializing invasion.")
    ResetMap()
    GetNodes()
    if #vipd.EnemyNodes + #vipd.CitizenNodes < 50 then
        AdventureSystem = false        
        BroadcastError("Can't init invasion because "..game.GetMap().." has less than 50 AI nodes!")
    else
        AdventureSystem = true
        CheckEnemyNodes()
        CheckCitizenNodes()
    end
end

function StopAdventureSystem()
    MsgCenter("Shutting down invasion.")
    AdventureSystem = false
    ResetMap()
end

function ResetMap()
    InitSystemGlobals()
    game.CleanUpMap(false, {} )
    for k, ply in pairs(player.GetAll()) do
        ply:StripWeapons()
        ply:Give("weapon_crowbar")
        ply:Give("weapon_physcannon")
        SetPoints(ply, 0)
        ply:SetHealth(100)
        ply:SetArmor(0)
    end
end

function CheckEnemyNodes()
    local nodes = vipd.EnemyNodes
    for i = currentEnemies+1, MaxEnemies() do
        local key = GetClosestValidNode(nodes)
        if key then
            local node = table.remove(nodes, key)
            if SpawnEnemy(node) then currentEnemies = currentEnemies + 1 end
        end
    end
end

function MaxEnemies()
    return EnemiesPerPlayer * #player.GetAll()
end

function CheckCitizenNodes()
    local nodes = vipd.CitizenNodes
    for i = currentCitizens+1, MaxCitizens() do
        local key = GetClosestValidNode(nodes)
        local node = table.remove(nodes, key)
        SpawnCitizen(node)
        currentCitizens = currentCitizens + 1
    end
end

function MaxCitizens()
    return CitizensPerPlayer * #player.GetAll()
end

function GetClosestValidNode(nodes)
    local closest = nil
    local closestDistance = 10000
    for k, node in pairs(nodes) do
        if IsNodeValid(node) then
            local farthestPlayerDistance = 0
            for k, ply in pairs(player.GetAll()) do
                local distance = node.pos:Distance(ply:GetPos())
                if distance > farthestPlayerDistance then
                    farthestPlayerDistance = distance
                end
            end
            if farthestPlayerDistance < closestDistance then
                closest = k
                closestDistance = farthestPlayerDistance
            end
        end
    end
    return closest
end

function SpawnEnemy(node)
    -- TODO Check for Air nodes and only spawn npcs with flying
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
            local validForNode = CheckNodeType(node, npc)
            if Weapon and validForNode then table.insert(possibleNpcs, pNPC) end
        end
    end
    if #possibleNpcs > 0 then
        local Angles = Angle(0, 0, 0)
        local cNPC = ChooseNPC(possibleNpcs)
        local NPC = VipdSpawnNPC(cNPC.Class, Position, Angles, 0, cNPC.Weapon, Team)
        HatePlayersAndVips(NPC)
        NPC.isEnemy = true
        return NPC
    else
        VipdLog(vINFO, "No valid NPC found for Node type: "..node.type)
    end
end

function CheckNodeType(node, npc)
    if (node.type == 2 and not npc.flying) or (node.type == 3 and npc.flying) then
        return true
    end
    VipdLog(vDEBUG,"Node type "..node.type.." not valid for "..npc.name)
    return false
end


function GetMaxEnemyValue()
    return GetAverageTier() * 5 + 4
end

function GetAverageTier()
    local gradeSum = 0
    for k, ply in pairs(player.GetAll()) do
        gradeSum = gradeSum + GetGrade(ply)
    end
    local avgTier = math.floor(gradeSum / #player.GetAll()) + 1
    if avgTier < 1 then avgTier = 1 end
    return avgTier
end

--60% chance of picking the highest value NPC
function ChooseNPC(possibleNpcs)
    local cNPC = possibleNpcs[math.random(#possibleNpcs)]
    local cValue = vipd_npcs[cNPC.Class].value + vipd_weapons[cNPC.Weapon].npcValue
    local percent = math.random(100)
    if percent > 40 then
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

function GetWeapon(Class, maxWeaponValue)
    local NPCList = list.Get("NPC")
    local NPCData = NPCList[Class]
    local Weapon = "none"
    local pWeapons = { }
    if (NPCData and NPCData.Weapons) then
        for k, weaponClass in pairs(NPCData.Weapons) do
            local vipd_weapon = vipd_weapons[weaponClass]
            if not vipd_weapon then
                VipdLog(vWARN, weaponClass.." is not defined in the config, but "..Class.." uses it!")
            else
                local npcValue = vipd_weapons[weaponClass].npcValue
                if npcValue <= maxWeaponValue then
                    table.insert(pWeapons, weaponClass)
                end
            end
        end
    end
    if #pWeapons > 0 then
        VipdLog(vDEBUG, "Randomly choosing weapon")
        Weapon = pWeapons[math.random(#pWeapons)]
        VipdLog(vDEBUG, "Chose weapon "..Weapon.." for "..Class)
    elseif (NPCData and NPCData.Weapons) then
        return false
    end
    return Weapon
end

function SpawnCitizen(node)
    local Team = "Citizens"
    local Position = node.pos
    local Weapon = "none"
    local Angles = Angle(0, 0, 0)
    local Class = "npc_citizen"
    local NPC = VipdSpawnNPC(Class, Position, Angles, 0, Weapon, Team)
    LikePlayersAndVips(NPC)
    NPC.isCitizen = true
    return NPC
end

function SpawnVIP(Player)
    local vStart = Player:GetShootPos()
    local vForward = Player:GetAimVector()

    local trace = { }
    trace.start = vStart
    trace.endpos = vStart + vForward * 2048
    trace.filter = Player

    tr = util.TraceLine(trace)
    Position = tr.HitPos
    Normal = tr.HitNormal
    local vip_npc = vipd_vips[math.random(#vipd_vips)]
    local Class = vip_npc.class
    local NPCList = list.Get("NPC")
    local NPCData = NPCList[Class]
    local Offset = NPCData.Offset or 32
    Position = Position + Normal * Offset
    -- Rotate to face Player (expected behaviour)
    local Angles = Angle(0, 0, 0)
    if (IsValid(Player)) then
        Angles = Player:GetAngles()
    end
    Angles.pitch = 0
    Angles.roll = 0
    Angles.yaw = Angles.yaw + 180
    if (NPCData.Rotate) then Angles = Angles + NPCData.Rotate end

    local NPC = VipdSpawnNPC(Class, Position, Angles, VipMaxHealth, "none", "VIP")

    VipName = vip_npc.name
    if VipName == "" then VipName = NPCData.Name end
    NPC:UseFollowBehavior()
    NPC:AddRelationship("player D_LI 98")
    NPC:AddEntityRelationship(player.GetAll()[1], D_LI, 99)
    return NPC
end

function HatePlayersAndVips(NPC)
    NPC:AddRelationship("player D_HT 998")
--NPC:AddEntityRelationship(VIP, D_HT, 999)
end

--TODO: AddLikeSquadmates (vortigaunt and stalker don't like each other)

function LikePlayersAndVips(NPC)
    NPC:AddRelationship("player D_LI 999")
--NPC:AddEntityRelationship(VIP, D_LI, 999)
end

function VipdSpawnNPC(Class, Position, Angles, Health, Equipment, Team)
    VipdLog(vDEBUG, "Spawning: " .. Class.." with "..Health.." health and a " .. Equipment.. " at "..tostring(Position))
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
    VipdLog(vDEBUG, Class.." has think "..tostring(NPC:HasSpawnFlags(SF_NPC_ALWAYSTHINK)).." and "..SpawnFlags)
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
        VipdLog(vDEBUG, "Gave "..Class.." a "..Equipment)
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

--Using
local function Rescue(ply, ent)
    timer.Simple (1, function () if (IsValid (ent) ) then ent:Remove () end end )

    -- Make it non solid
    ent:SetNotSolid (true)
    ent:SetMoveType (MOVETYPE_NONE)
    ent:SetNoDraw (true)

    -- Send Effect
    local ed = EffectData ()
    ed:SetEntity (ent)
    util.Effect ("entity_remove", ed, true, true)
    currentCitizens = currentCitizens - 1
    CheckCitizenNodes ()
    Notify (ply, "You rescued a citizen!")
    AddPoints(ply, CitizenPointValue)
    --TODO Give health/armor for rescue
end

function GM:FindUseEntity (ply, ent)
    if ent.isCitizen then
        Rescue(ply, ent)
    end
    return ent
end

