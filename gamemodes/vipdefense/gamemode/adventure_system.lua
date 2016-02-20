function InitAdventureSystem()
    MsgCenter("Initializing adventure system.")
    AdventureSystem = true
    ResetMap()
    GetNodes()
    if #vipd.nodes > 0 then 
        CheckNodes()
    else 
        BroadcastError("Can't init adventure system because "..game.GetMap().." has no AI nodes!")
    end
end

function StopAdventureSystem()
    MsgCenter("Shutting down adventure system.")
    AdventureSystem = false
    ResetMap()
end


function CheckNodes()
    local nodes = vipd.nodes
    for i = currentEnemies, MaxEnemies() do
        local key = GetClosestValidNode()
        local node = table.remove(nodes, key)
        local enemy = SpawnEnemy(node)
        enemy.isEnemy = true
        currentEnemies = currentEnemies + 1
    end
    VipdLog (vDEBUG, "Nodes after spawning: " .. #nodes)
end

function MaxEnemies()
    return EnemiesPerPlayer * #player.GetAll()
end

function GetClosestValidNode()
    local nodes = vipd.nodes
    local closest = nil
    local closestDistance = maxSpawnDistance
    for k, node in pairs(nodes) do
        if IsNodeValid(node) then
            local maxDistance = 0
            for k, ply in pairs(player.GetAll()) do
                local distance = node.pos:Distance(ply:GetPos())
                if distance > maxDistance then
                    maxDistance = distance
                end
            end
            if maxDistance < closestDistance then
                closest = k
                closestDistance = maxDistance
            end
        end
    end
    return closest
end

function SpawnEnemy(node)
    local Team = "Zombies"
    local Position = node.pos
    local maxValue = GetMaxNPCValueForWave()
    local possibleNpcs = { }
    local Weapon = "none"
    for Class, npc in pairs(vipd_npcs) do
        if npc.value <= maxValue and npc.team == Team then
            local weaponValue = maxValue - npc.value
            Weapon = GetWeapon(Class, weaponValue)
            local pNPC = { }
            pNPC.Class = Class
            pNPC.Weapon = Weapon
            table.insert(possibleNpcs, pNPC)
        end
    end
    local Angles = Angle(0, 0, 0)
    local cNPC = ChooseNPC(possibleNpcs)
    local NPC = VipdSpawnNPC(cNPC.Class, Position, Angles, 0, cNPC.Weapon, Team)
    HatePlayersAndVips(NPC)
    table.insert(WaveEnemyTable, NPC)
    return NPC
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
        VipdLog(vERROR, Class.." uses weapons but wasn't assigned one")
    end
    return Weapon
end

function ResetMap()
    currentEnemies = 0
    game.CleanUpMap(false, {} )
    for k, ply in pairs(player.GetAll()) do
        ply:StripWeapons()
        ply:Give("weapon_crowbar")
        ply:Give("weapon_physcannon")
        ply:SetFrags(0)
        ply:SetHealth(100)
        ply:SetArmor(0)
    end
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

function LikePlayersAndVips(NPC)
    NPC:AddRelationship("player D_LI 999")
--NPC:AddEntityRelationship(VIP, D_LI, 999)
end

function VipdSpawnNPC(Class, Position, Angles, Health, Equipment, Team)
    VipdLog(vDEBUG, "Spawning: " .. Class.." with "..Health.." health and a " .. Equipment.. " at "..tostring(Position))
    local NPCList = list.Get("NPC")
    local NPCData = NPCList[Class]
    --removed offset because it's multiplied by the tr.Normal which doesn't exist here, need logic to replace offset
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
    else
        -- This is a hack because currently only enemies have a team
        NPC:SetKeyValue("citizentype", 4)
    end
    NPC:Spawn()
    NPC:Activate()
    if Health > 0 then
        NPC:SetMaxHealth(Health)
        NPC:SetHealth(Health)
    end
    return NPC
end