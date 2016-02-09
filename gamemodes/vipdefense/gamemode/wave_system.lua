function Debug()
    if not navmesh.IsLoaded() then
        print("Generating new navmesh...")
        navmesh.BeginGeneration()
        return
    end
    -- TODO Reset all player frags
    local ply = player.GetAll()[1]
    local startPos = ply:GetPos() + Vector(0, 30, 20)
    if VIP == nil or not IsValid(VIP) then
        VIP = SpawnVIP(ply, startPos)
    end
    for l, w in pairs(navmesh.GetAllNavAreas()) do
        local distance = w:GetCenter():Distance(VIP:GetPos())
        local totalWaveValue = GetTotalWaveNPCValue()
        local team = "zombies"
        if distance > minSpawnDist and distance < maxSpawnDist then
            if currWaveValue < totalWaveValue then
                currWaveValue = currWaveValue + SpawnEnemyNPC(team, w:GetCenter())
            end
        end
    end
    PrintTable(waveNpcTable)
    waveIsInProgress = true
    MsgCenter("WAVE " .. currentWave .. " HAS BEGUN")
    return
end

function SpawnEnemyNPC(team, startPos)
    local maxValue = GetMaxNPCValueForWave()
    local totalWaveValue = GetTotalWaveNPCValue()
    if maxValue + currWaveValue > totalWaveValue then maxValue = totalWaveValue - currWaveValue end
    if maxValue == 0 then return end
    local npcEnt = GetEnemyNPC(team, maxValue)
    -- if CAP_MOVE_FLY then spawn a lot higher?
    npcEnt:SetPos(startPos + Vector(0, 0, 20))
    npcEnt:Spawn()
    table.insert(waveNpcTable, npcEnt)
    return GetNpcPointValue(npcEnt)
    -- if bit.band(ent:CapabilitiesGet(), CAP_MOVE_GROUND) then print(className .. " can move ground!") end
end

function GetEnemyNPC(team, maxValue)
    local maxValue = GetMaxNPCValueForWave()
    local totalWaveValue = GetTotalWaveNPCValue()
    if maxValue + currWaveValue > totalWaveValue then maxValue = totalWaveValue - currWaveValue end
    if maxValue == 0 then return end
    local possibleNpcs = { }
    local npcCount = 0
    for className, npc in pairs(vipd_npcs) do
        if npc.value <= maxValue and npc.team == team then
            npcEnt = ents.Create(className)
            table.insert(possibleNpcs, npcEnt)
            npcCount = npcCount + 1
        end
    end
    -- if npcCount == 0 ERROR!
    return possibleNpcs[math.random(npcCount)]
    -- Handle exceptions where no entities have the right value
    -- Use minvalue for team
end

function onThink()
    local waveTotal = 0
    for k, npc in pairs(waveNpcTable) do
        waveTotal = waveTotal + 1
        if npc:IsValid() and npc:Health() > 0 then
            setBehavior(npc)
        else
            table.remove(waveNpcTable, k)
        end
    end
    local vipHealth = 0
    if IsValid(VIP) then vipHealth = VIP:Health() end
    netTable = {
        ["waveTotal"] = waveTotal,
        ["vipHealth"] = vipHealth,
        ["vipName"] = vipName
    }
    WaveUpdateClient(netTable)
    if waveIsInProgress then
        if vipHealth <= 0 then
            FailedWave()
        elseif waveTotal == 0 then
            CompletedWave()
        end
    end
end

function FailedWave()
    MsgCenter("THE VIP DIED! YOU LOSE!")
    print("THE VIP DIED! YOU LOSE!")
    currentWave = 1
    ResetWave()
end

function CompletedWave()
    MsgCenter("ALL ENEMIES DEFEATED! YOU WIN!")
    print("ALL ENEMIES DEFEATED! YOU WIN!")
    currentWave = currentWave + 1
    ResetWave()
end

function ResetWave()
    waveIsInProgress = false
    if not waveTable == nil then
        for k, npc in pairs(waveTable) do
            npc:TakeDamage( 999, game.GetWorld(), game.GetWorld() )
            npc:Remove()
            waveTable.remove(k)
        end
    end
    currWaveValue = 0
end

function SpawnVIP(Player, Position)
    local Class = "npc_elsa"
    local NPCList = list.Get("NPC")
    local NPCData = NPCList[Class]

    local NPC = ents.Create(NPCData.Class)

    NPC:SetPos(Position)

    -- Rotate to face player (expected behaviour)
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

    NPC:SetMaxHealth(vipMaxHealth)

    NPC:Spawn()
    NPC:Activate()
    vipName = NPCData.Name
    NPC:SetHealth(vipMaxHealth)
    NPC:UseFollowBehavior()
    NPC:AddRelationship("player D_LI 99")
    return NPC
end