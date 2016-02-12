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
        print("Generating new navmesh...")
        BroadcastError("This map has no navmesh loaded.")
        -- navmesh.BeginGeneration()
        return
    end
    timer.Stop("Wave Timer")
    if CurrentWave == 1 then
        ResetPlayers()
        VIP = SpawnVIP(player.GetAll()[1], startPos)
    end
    local team = vipd_npc_teams[math.random(#vipd_npc_teams)]
    -- local team = vipd_npc_teams[1]
    print("Wave is of team: " .. team.name)
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
    PrintTable(WaveEnemyTable)
    WaveIsInProgress = true
    MsgCenter("WAVE " .. CurrentWave .. " HAS BEGUN")
    return
end

function SpawnEnemyNPC(team, startPos)
    local maxValue = GetMaxNPCValueForWave()
    local totalWaveValue = GetTotalWaveNPCValue()
    if maxValue + CurrentWaveValue > totalWaveValue then maxValue = totalWaveValue - CurrentWaveValue end
    if maxValue == 0 then return 0 end
    local npcEnt = GetEnemyNPC(team, maxValue)
    -- if CAP_MOVE_FLY then spawn a lot higher?
    npcEnt:SetPos(startPos + Vector(0, 0, 20))
    npcEnt:Spawn()
    npcEnt:Activate()
    table.insert(WaveEnemyTable, npcEnt)
    return npcEnt.WaveValue
end

function GetEnemyNPC(team, maxValue)
    local maxValue = GetMaxNPCValueForWave()
    local totalWaveValue = GetTotalWaveNPCValue()
    local possibleNpcs = { }
    for className, npc in pairs(vipd_npcs) do
        if npc.value <= maxValue and npc.team == team then
            npcEnt = ents.Create(className)
            npcEnt.WaveValue = npc.value
            if npc.useWeapons then
                local Weapon = GetWeapon(maxValue - npc.value)
                local WeaponEnt = npcEnt:Give(Weapon)
                print("Weapon given: " .. WeaponEnt:GetClass())
                npcEnt:SetKeyValue("additionalequipment", Weapon)
                npcEnt.Equipment = Weapon
                npcEnt.WaveValue = npc.value + vipd_weapons[Weapon].npcValue
            end
            table.insert(possibleNpcs, npcEnt)
        end
    end
    return possibleNpcs[math.random(#possibleNpcs)]
end

function GetWeapon(weaponValue)
    local weaponClass = "weapon_crowbar"
    for class, weapon in pairs(vipd_weapons) do
        if weapon.npcValue <= weaponValue and
            weapon.npcValue > vipd_weapons[weaponClass].npcValue then
            weaponClass = class
        end
    end
    return weaponClass
end

function onThink()
    for k, npc in pairs(WaveEnemyTable) do
        if npc:IsValid() and npc:Health() > 0 then
            setBehavior(npc)
        else
            table.remove(WaveEnemyTable, k)
        end
    end
    local VipHealth = 0
    if IsValid(VIP) then VipHealth = VIP:Health() end
    netTable = {
        ["waveTotal"] = #WaveEnemyTable,
        ["VipHealth"] = VipHealth,
        ["VipName"] = VipName,
        ["WaveIsInProgress"] = WaveIsInProgress,
        ["CurrentWave"] = CurrentWave
    }
    WaveUpdateClient(netTable)
    if WaveIsInProgress then
        if VipHealth <= 0 then
            FailedWave()
        elseif #WaveEnemyTable == 0 then
            CompletedWave()
        end
    end
end

function FailedWave()
    MsgCenter(VipName .. " THE VIP DIED! YOU LOSE!")
    CurrentWave = 1
    ResetPlayers()
    ResetWave()
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
        print("Wave Enemy Table not empty, removing all remaining enemies")
        for i = 0, #WaveEnemyTable, 1 do
            local npc = table.remove(WaveEnemyTable)
            if IsValid(npc) then
                npc:TakeDamage(999, game.GetWorld(), game.GetWorld())
                npc:Remove()
            end
        end
    else
        print("Wave enemy table is empty, skipping removal")
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

    --
    -- Offset the position
    --
    local Offset = NPCData.Offset or 32
    Position = Position + Normal * Offset

    local NPC = ents.Create(NPCData.Class)

    NPC:SetPos(Position)

    -- Rotate to face Player (expected behaviour)
    local Angles = Angle(0, 0, 0)

    if (IsValid(Player)) then
        Angles = Player:GetAngles()
    end

    Angles.pitch = 0
    Angles.roll = 0
    Angles.yaw = Angles.yaw + 180

    if (NPCData.Rotate) then Angles = Angles + NPCData.Rotate end

    NPC:SetAngles(Angles)

    --
    -- This NPC has a special model we want to define
    --
    if (NPCData.Model) then
        NPC:SetModel(NPCData.Model)
    end

    --
    -- This NPC has a special texture we want to define
    --
    if (NPCData.Material) then
        NPC:SetMaterial(NPCData.Material)
    end

    --
    -- Spawn Flags
    --
    local SpawnFlags = bit.bor(SF_NPC_FADE_CORPSE, SF_NPC_ALWAYSTHINK)
    if (NPCData.SpawnFlags) then SpawnFlags = bit.bor(SpawnFlags, NPCData.SpawnFlags) end
    if (NPCData.TotalSpawnFlags) then SpawnFlags = NPCData.TotalSpawnFlags end
    NPC:SetKeyValue("spawnflags", SpawnFlags)

    --
    -- Optional Key Values
    --
    if (NPCData.KeyValues) then
        for k, v in pairs(NPCData.KeyValues) do
            NPC:SetKeyValue(k, v)
        end
    end

    --
    -- This NPC has a special skin we want to define
    --
    if (NPCData.Skin) then
        NPC:SetSkin(NPCData.Skin)
    end

    NPC:SetMaxHealth(VipMaxHealth)
    NPC:Spawn()
    NPC:Activate()
    VipName = vip_npc.name
    if VipName == "" then VipName = NPCData.Name end
    NPC:SetHealth(VipMaxHealth)
    NPC:UseFollowBehavior()
    NPC:AddRelationship("Player D_LI 99")
    return NPC
end