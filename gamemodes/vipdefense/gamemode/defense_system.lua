function InitDefenseSystem()
    MsgCenter("Initializing invasion.")
    ResetMap()
    GetNodes()
    if #vipd.EnemyNodes + #vipd.CitizenNodes < 50 then
        DefenseSystem = false
        BroadcastError("Can't init invasion because "..game.GetMap().." has less than 50 AI nodes!")
    else
        DefenseSystem = true
        CheckEnemyNodes()
        CheckCitizenNodes()
        totalCitizens = #vipd.CitizenNodes
        deadCitizens = 0
        rescuedCitizens = 0
    end
end

function StopDefenseSystem()
    MsgCenter("Shutting down invasion.")
    DefenseSystem = false
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
    if #nodes == 0 then return end
    for i = currentEnemies+1, MaxEnemies() do
        local key = GetClosestValidNode(nodes)
        if key then
            local node = table.remove(nodes, key)
            if SpawnEnemy(node) then
                currentEnemies = currentEnemies + 1
            else
                VipdLog(vWARN, "Spawning enemy failed!")
            end
        else
            VipdLog(vWARN, "No valid Citizen nodes found!")
        end
    end
end

function MaxEnemies()
    local maxTotal = MaxNpcs - MaxCitizens()
    local maxPer = EnemiesPerPlayer * #player.GetAll()
    if maxPer > maxTotal then
        return maxTotal
    else
        return maxPer
    end
end

function CheckCitizenNodes()
    local nodes = vipd.CitizenNodes
    if #nodes == 0 then return end
    for i = currentCitizens+1, MaxCitizens() do
        local key = GetClosestValidNode(nodes)
        if key then
            local node = table.remove(nodes, key)
            if SpawnCitizen(node) then
                currentCitizens = currentCitizens + 1
            else
                VipdLog(vWARN, "Spawning citizen failed!")
            end
        else
            VipdLog(vWARN, "No valid Citizen nodes found!")
        end
    end
end

function MaxCitizens()
    return CitizensPerPlayer * #player.GetAll()
end

function GetClosestValidNode(nodes)
    local closest = nil
    local closestDistance = MaxDistance
    local validDistance = false
    local validValue = false
    for k, node in pairs(nodes) do
        local closestPlayer = GetClosestPlayer(node.pos, MaxDistance, minSpawnDistance)
        if closestPlayer then
            validDistance = true
            if GetMaxEnemyValue() >= GetMinTeamValue(node.team) or node.team == VipdPlayerTeam then
                validValue = true
                local playerDistance = 0
                for k, ply in pairs(player.GetAll()) do
                    local distance = node.pos:Distance(ply:GetPos())
--                    if distance > farthestPlayerDistance then
--                        farthestPlayerDistance = distance
--                    end
                    if distance < playerDistance then
                        playerDistance = distance
                    end
                end
                if playerDistance < closestDistance then
                    closest = k
                    closestDistance = playerDistance
                end
            end
        end
    end
    if not closest then
        if validDistance and validValue then VipdLog(vWARN, "No valid node found for no reason! Maybe there are no nodes: "..#nodes)
        elseif validDistance and not validValue then VipdLog(vWARN, "No valid node found because there were no nodes with a valid value!")
        elseif not validDistance then VipdLog(vWARN, "No valid node found with a valid distance!")
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
        NPC.isEnemy = true
        NPC:SetNPCState(NPC_STATE_ALERT)
        NPC:SetSchedule(SCHED_ALERT_WALK)
        return NPC
    else
        VipdLog(vWARN, "No valid NPC found for Node type: "..node.type)
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
    return GetAverageTier() * 3 + 2
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

function GetMinTeamValue(teamName)
    local minValue = 1000
    for k, npc in pairs(vipd_npcs) do
        --Assume NPC uses weapon with value of 1
        local value = npc.value + 1
        if npc.team == teamName and minValue > value then
            minValue = value
        end
    end
    return minValue
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
    local Team = VipdPlayerTeam
    local Position = node.pos
    local Weapon = "none"
    local Angles = Angle(0, 0, 0)
    local Class = "npc_citizen"
    local NPC = VipdSpawnNPC(Class, Position, Angles, 0, Weapon, Team)
    NPC.isCitizen = true
    SetCitizenRelationships(NPC)
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

-- There is lots of redundancy in setting the relationships, but that's because sometimes it doesn't seem to work.
function SetEnemyRelationships(NPC)
    local squad = NPC:GetKeyValues()["squadname"]
    for key, ent in pairs(ents.GetAll()) do
        if ent.isCitizen or ent.isEnemy then
            local entSquad = ent:GetKeyValues()["squadname"]
            local entClass = ent:GetClass()
            if squad == entSquad then
                NPC:AddEntityRelationship(ent, D_LI, 99)
                NPC:AddRelationship(entClass.." D_LI 99")
                ent:AddEntityRelationship(NPC, D_LI, 99)
                ent:AddRelationship(NPC:GetClass().." D_LI 99")
            else
                local hate = 90
                if ent.isCitizen then hate = 95 end
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

function SetCitizenRelationships(NPC)
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
    if Team ~= VipdPlayerTeam then SetEnemyRelationships(NPC)
    else SetCitizenRelationships(NPC) end
    NPC:Spawn()
    NPC:Activate()
    if Health > 0 then
        NPC:SetMaxHealth(Health)
        NPC:SetHealth(Health)
    end
    return NPC
end

--=================--
--Rescuing citizens--
--=================--

local function Rescue(ply, ent)
    timer.Simple (1, function () if (IsValid (ent) ) then ent:Remove () end end )
    local healthId = math.random(5)
    CitizenSay(ent, "health0"..healthId)

    -- Make it non solid
    ent:SetNotSolid (true)
    ent:SetMoveType (MOVETYPE_NONE)
    ent:SetNoDraw (true)

    -- Send Effect
    local ed = EffectData ()
    ed:SetEntity (ent)
    util.Effect ("entity_remove", ed, true, true)
    Notify (ply, "You rescued a citizen!")
    AddPoints(ply, CitizenPointValue)
    GiveBonus(ply)
    currentCitizens = currentCitizens - 1
    rescuedCitizens = rescuedCitizens + 1
    CheckCitizenNodes ()--
end

function GM:FindUseEntity (ply, ent)
    if ent.isCitizen then
        Rescue(ply, ent)
    else
        return ent
    end
end
















































































































































