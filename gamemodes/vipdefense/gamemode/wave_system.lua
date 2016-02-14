function InitWaveSystem()
    local mapName = game.GetMap()
    local nodeFile = file.Find(mapName..".ain", "GAME", "namedesc" )
    VipdLog(vDEBUG, "Checking for AI Nodes: ")
    VipdLog(vDEBUG, nodeFile) 
    if not navmesh.IsLoaded() then
        BroadcastError(mapName.." has no navmesh loaded. Type vipd_navmesh to generate a new navmesh. Attempting to play without one!")
        --return
    end
    WaveSystemPaused = false
    NextWave()
end

function NextWave()
    if WaveSystemPaused then
        return
    end
    timer.Create("Wave Timer", TimeBetweenWaves, 5, BeginWave)
    timer.Start("Wave Timer")
    timer.Create("Wave Timer Display Counter", 1, TimeBetweenWaves - 1, function()
        MsgCenter("WAVE " .. CurrentWave .. " BEGINS IN " .. math.ceil(timer.TimeLeft("Wave Timer")) .. "..");
    end )
    timer.Start("Wave Timer Display Counter")
end

function PauseWaveSystem()
    WaveSystemPaused = true
    timer.Stop("Wave Timer")
    timer.Stop("Wave Timer Display Counter")
    BroadcastNotify("The wave system is paused!")
end

function BeginWave()
    if WaveIsInProgress then return end
    timer.Stop("Wave Timer")
    if CurrentWave == 1 then
        ResetPlayers()
        VIP = SpawnVIP(player.GetAll()[1])
    end
    local team = vipd_npc_teams[math.random(#vipd_npc_teams)]
    VipdLog(vINFO, "Wave is of team: " .. team.name)
    local totalWaveValue = GetTotalWaveNPCValue()
    if MapHasNavmesh then
        SpawnWithNavmesh(team, totalWaveValue)
    else
        SpawnWithoutNavmesh(team, totalWaveValue)
    end
    
    VipdLog(vINFO, "Max NPC value: "..GetMaxNPCValueForWave())
    VipdLog(vINFO, "Total Max NPC value: "..totalWaveValue)
    VipdLog(vINFO, WaveEnemyTable)
    WaveIsInProgress = true
    MsgCenter("WAVE " .. CurrentWave .. " HAS BEGUN")
    return
end

function SpawnWithNavmesh(team, totalWaveValue)
    for l, w in pairs(navmesh.GetAllNavAreas()) do
        local distance = w:GetCenter():Distance(VIP:GetPos())
        if distance > minSpawnDist and distance < maxSpawnDist then
            if CurrentWaveValue < totalWaveValue and CurrentWaveValue + team.minValue <= totalWaveValue then
                local npcValue = SpawnEnemyNPC(team.name, w:GetCenter())
                if npcValue < 1 then break end
                CurrentWaveValue = CurrentWaveValue + npcValue
            end
        end
    end
end

function SpawnWithoutNavmesh(team, totalWaveValue)
    local vipPos = VIP:GetPos()
    while CurrentWaveValue < totalWaveValue and CurrentWaveValue + team.minValue <= totalWaveValue do
        local position = Vector(math.random(-maxSpawnDist, maxSpawnDist) + vipPos.x, math.random(-maxSpawnDist, maxSpawnDist) + vipPos.y, math.random(-500, 500) + vipPos.z)
        local distance = position:Distance(vipPos)
        if distance > minSpawnDist and distance < maxSpawnDist and util.IsInWorld( position ) then
            local npcValue = SpawnEnemyNPC(team.name, position)
            if npcValue < 1 then break end
            CurrentWaveValue = CurrentWaveValue + npcValue
        end
    end
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
            if !vipd_npcs[Class].useWeapons or Weapon != "none" then
                local pNPC = { }
                pNPC.Class = Class
                pNPC.Weapon = Weapon
                table.insert(possibleNpcs, pNPC)
            else
                VipdLog(vDEBUG, "Skipping NPC because they use weapons and they didn't have one")
            end
        end
    end
    local Angles = Angle(0, 0, 0)
    local cNPC = ChooseNPC(possibleNpcs)
    local NPC = VipdSpawnNPC(cNPC.Class, Position, Angles, 0, cNPC.Weapon, Team)
    HatePlayersAndVIP(NPC)
    table.insert(WaveEnemyTable, NPC)
    return GetNpcPointValue(NPC)
end

--If wave is less than 60% full, use the highest value NPC available
--Otherwise choose randomly
function ChooseNPC(possibleNpcs)
    local cNPC = possibleNpcs[math.random(#possibleNpcs)]
    local cValue = GetPointValue(cNPC.Class, 1, cNPC.Weapon)
    local percent = GetTotalWaveNPCValue() * .6
    if CurrentWaveValue < percent then
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
    if (NPCData && NPCData.Weapons) then
        for k, weaponClass in pairs(NPCData.Weapons) do
            local npcValue = vipd_weapons[weaponClass].npcValue
            if npcValue <= maxWeaponValue then
                table.insert(pWeapons, weaponClass)
            end
        end
    end
    if #pWeapons  > 0 then
        VipdLog(vDEBUG, "Randomly choosing weapon")
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
end

function ResetPlayers()
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
    CheckBonuses()
    NextWave()
end

function CheckBonuses()
    if VIP:Health() == 100 then
        BroadcastNotify("The VIP still has 100 health, everyone gets a bonus!")
        for k, ply in pairs(player.GetAll()) do
            GiveGradeBonus(ply)
        end
    else
        VIP:SetHealth(100)
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
    NPC:AddRelationship("player D_LI 98")
    NPC:AddEntityRelationship(player.GetAll()[1], D_LI, 99)
    return NPC
end

function HatePlayersAndVIP(NPC)
    NPC:AddRelationship("player D_HT 998")
    NPC:AddEntityRelationship(VIP, D_HT, 999)
end

function LikePlayersAndVIP(NPC)
    NPC:AddRelationship("player D_LI 999")
    NPC:AddEntityRelationship(VIP, D_LI, 999)
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
    VipdLog(vDEBUG, Class.." has think "..tostring(NPC:HasSpawnFlags(SF_NPC_ALWAYSTHINK)).." and "..SpawnFlags)
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