function InitWaveSystem()
    timer.Create("Wave Timer", TimeBetweenWaves, 5, BeginWave)
    timer.Start("Wave Timer")
    timer.Create("Wave Timer Display Counter", 1, TimeBetweenWaves - 1, function()
        MsgCenter("WAVE " .. CurrentWave .. " BEGINS IN " .. math.ceil(timer.TimeLeft("Wave Timer")) .. "..");
    end )
    timer.Start("Wave Timer Display Counter")
end

function BeginWave()
    if WaveIsInProgress then return end
    if not navmesh.IsLoaded() then
        BroadcastError("This map has no navmesh loaded.")
        --VipdLog(vINFO, "Generating new navmesh...")
        -- navmesh.BeginGeneration()
        return
    end
    timer.Stop("Wave Timer")
    if CurrentWave == 1 then
        ResetPlayers()
        VIP = SpawnVIP(player.GetAll()[1], startPos)
    end
    local team = vipd_npc_teams[math.random(#vipd_npc_teams)]
    VipdLog(vDEBUG, "Wave is of team: " .. team.name)
    for l, w in pairs(navmesh.GetAllNavAreas()) do
        local distance = w:GetCenter():Distance(VIP:GetPos())
        local totalWaveValue = GetTotalWaveNPCValue()
        if distance > minSpawnDist and distance < maxSpawnDist then
            if CurrentWaveValue < totalWaveValue and CurrentWaveValue + team.minValue <= totalWaveValue then
                local npcValue = SpawnEnemyNPC(team.name, w:GetCenter())
                if npcValue < 1 then break end
                CurrentWaveValue = CurrentWaveValue + npcValue
            end
        end
    end
    VipdLog(vINFO, WaveEnemyTable)
    WaveIsInProgress = true
    MsgCenter("WAVE " .. CurrentWave .. " HAS BEGUN")
    return
end

function SpawnEnemyNPC(Team, Position)
    local maxValue = GetMaxNPCValueForWave()
    local totalWaveValue = GetTotalWaveNPCValue()
    if maxValue + CurrentWaveValue > totalWaveValue then maxValue = totalWaveValue - CurrentWaveValue end
    if maxValue == 0 then return 0 end
    local totalWaveValue = GetTotalWaveNPCValue()
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
    local cNPC = possibleNpcs[math.random(#possibleNpcs)]
    local NPC = VipdSpawnNPC(cNPC.Class, Position, Angles, 0, cNPC.Weapon)
    HatePlayersAndVIP(NPC)
    table.insert(WaveEnemyTable, NPC)
    return GetNpcPointValue(NPC)
end

function GetWeapon(Class, maxWeaponValue)
    local NPCList = list.Get("NPC")
    local NPCData = NPCList[Class]
    local Weapon = "none"
    local pWeapons = { }
    if (NPCData.KeyValues) then
        for k, weaponClass in pairs(NPCData.Weapons) do
            local npcValue = vipd_weapons[weaponClass].npcValue
            if npcValue <= maxWeaponValue then
                table.insert(pWeapons, weaponClass)
            end
        end
    end
    if #pWeapons  > 0 then
        Weapon = pWeapons[math.random(#pWeapons)]
    end
    VipdLog(vDEBUG, "Chose weapon "..Weapon.." for "..Class)
    return Weapon
end

function FailedWave()
    MsgCenter(VipName .. " THE VIP DIED! YOU LOSE!")
    CurrentWave = 1
    ResetPlayers()
    ResetWave()
    game.CleanUpMap(false, {} )
end

function ResetPlayers()
    for k, ply in pairs(player.GetAll()) do
        ply:StripWeapons()
        ply:Give("weapon_crowbar")
        ply:Give("weapon_physcannon")
        ply:SetFrags(0)
        ply:SetHealth(100)
        ply:SetArmor(0)
    end
end

function ResetWave()
    WaveIsInProgress = false
    if #WaveEnemyTable > 0 then
        VipdLog(vDEBUG, "Wave Enemy Table not empty, removing all remaining enemies")
        for i = 0, #WaveEnemyTable, 1 do
            local npc = table.remove(WaveEnemyTable)
            if IsValid(npc) then
                npc:TakeDamage(999, game.GetWorld(), game.GetWorld())
                npc:Remove()
            end
        end
    else
        VipdLog(vDEBUG, "Wave enemy table is empty, skipping removal")
    end
    CurrentWaveValue = 0
end

function CompletedWave()
    MsgCenter("ALL ENEMIES DEFEATED! YOU WIN!")
    CurrentWave = CurrentWave + 1
    ResetWave()
    InitWaveSystem()
end

function SpawnVIP(Player, WeaponName)
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
    -- Rotate to face Player (expected behaviour)
    local Angles = Angle(0, 0, 0)
    if (IsValid(Player)) then
        Angles = Player:GetAngles()
    end
    Angles.pitch = 0
    Angles.roll = 0
    Angles.yaw = Angles.yaw + 180
    if (NPCData.Rotate) then Angles = Angles + NPCData.Rotate end

    local NPC = VipdSpawnNPC(Class, Position, Angles, VipMaxHealth, "none")

    VipName = vip_npc.name
    if VipName == "" then VipName = NPCData.Name end
    NPC:UseFollowBehavior()
    NPC:AddRelationship("player D_LI 99")
    return NPC
end

function HatePlayersAndVIP(NPC)
    NPC:AddRelationship("player D_HT 98")
    NPC:AddEntityRelationship(VIP, D_HT, 99)
end

function LikePlayersAndVIP(NPC)
    NPC:AddRelationship("player D_LI 99")
    NPC:AddEntityRelationship(VIP, D_LI, 99)
end

function VipdSpawnNPC(Class, Position, Angles, Health, Equipment)
    VipdLog(vDEBUG, "Spawning: " .. Class.." with "..Health.." health and a " .. Equipment.. " at "..tostring(Position))
    local NPCList = list.Get("NPC")
    local NPCData = NPCList[Class]
    local Offset = NPCData.Offset or 32
    Position = Position + Normal * Offset
    local NPC = ents.Create(NPCData.Class)
    NPC:SetPos(Position)
    NPC:SetAngles(Angles)
    if (NPCData.Model) then
        NPC:SetModel(NPCData.Model)
    end
    if (NPCData.Material) then
        NPC:SetMaterial(NPCData.Material)
    end
    local SpawnFlags = bit.bor(SF_NPC_FADE_CORPSE, SF_NPC_ALWAYSTHINK)
    if (NPCData.SpawnFlags) then SpawnFlags = bit.bor(SpawnFlags, NPCData.SpawnFlags) end
    if (NPCData.TotalSpawnFlags) then SpawnFlags = NPCData.TotalSpawnFlags end
    NPC:SetKeyValue("spawnflags", SpawnFlags)
    VipdLog(vINFO, Class.." has think "..tostring(NPC:HasSpawnFlags(SF_NPC_ALWAYSTHINK)).." and "..SpawnFlags)
    if (NPCData.KeyValues) then
        for k, v in pairs(NPCData.KeyValues) do
            NPC:SetKeyValue(k, v)
        end
    end
    if (NPCData.Skin) then
        NPC:SetSkin(NPCData.Skin)
    end
    if ( Equipment && Equipment != "none" ) then
        NPC:SetKeyValue("additionalequipment", Equipment)
        NPC.Equipment = Equipment
        VipdLog(vDEBUG, "Gave "..Class.." a "..Equipment)
    end
    NPC:Spawn()
    NPC:Activate()
    if Health > 0 then
        NPC:SetMaxHealth(Health)
        NPC:SetHealth(Health)
    end
    return NPC
end