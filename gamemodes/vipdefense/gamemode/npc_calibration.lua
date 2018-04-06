CalibrationEnabled = false
local calibration_prop
local calibration_npc
local calibration_vipd_npc
local spawn_countdown = 3
local total_deaths = 0
POINTS_INCREMENT = 20

local function GetNextNpcForCalibration()
    for class, npc in pairs(vipd_npcs) do
        if npc.spawnable and npc.enabled and npc.calibration < 0 then
            return npc
        end
    end
end

local function SpawnCalibrationNpc()
    if not CalibrationEnabled then
        vINFO("Canceled spawning NPC for calibration")
        return
    end
    if spawn_countdown > 0 then
        MsgCenter("Spawning NPC for calibration in " .. spawn_countdown)
        spawn_countdown = spawn_countdown - 1
        timer.Simple(1, SpawnCalibrationNpc)
    else
        spawn_countdown = 4
        calibration_vipd_npc = GetNextNpcForCalibration()
        if calibration_vipd_npc == nil then
            vWARN("No NPC found for calibration!")
            StopNpcCalibration()
            return
        end
        MsgCenter("Spawning " .. calibration_vipd_npc.name .. " for calibration!")
        local Team -- Unused
        local Position = calibration_prop:GetPos()
        local Offset = 64
        Position = Position + Vector(0, 0, 1) * Offset
        local Angles = Angle(0, 0, 0)

        calibration_npc = VipdSpawnNPC(calibration_vipd_npc.class, Position, Angles, 0, GetWeapon(calibration_vipd_npc.class, 1000), Team)
        SetEnemyRelationships(calibration_npc)
    end
end

local function InitNextCalibration()
    PersistSettings()
    spawn_countdown = 3
    total_deaths = 0
    -- Delay this, to remove any weapons picked up from the NPC that was killed
    timer.Simple(2, ResetLevelSystem)
    timer.Simple(2, SpawnCalibrationNpc)
end

local function SpawnCalibrationProp( ply )
    calibration_prop = DoPlayerEntitySpawn( ply, "prop_physics", "models/Gibs/HGIBS.mdl", 0, nil )
end

local function ResetCalibration()
    for key, class in pairs(vipd_npcs) do
        class.calibration = -1
    end
end

function StartNpcCalibration(ply, cmd, arguments)
    CalibrationEnabled = true
    vINFO("Starting NPC Calibration")
    if arguments[1] == "reset" then
        ResetCalibration()
    end
    SpawnCalibrationProp(ply)
    InitNextCalibration()
end

function StopNpcCalibration(ply, cmd, arguments)
    CalibrationEnabled = false
    if calibration_prop and calibration_prop:IsValid() then
        calibration_prop:Remove()
    end
    if calibration_npc and calibration_npc:IsValid() then
        calibration_npc:Remove()
    end
    calibration_prop = nil
    calibration_npc = nil
    calibration_vipd_npc = nil
end

local function GetCalibrationScore()
    local calibration_score = 100 * total_deaths
    for k, ply in pairs(player.GetAll()) do
        calibration_score = calibration_score + (100 - ply:Health())
    end
    return calibration_score
end

function CalibrationNpcKilled(victim, ply, inflictor)
    if calibration_npc == nil then
        return
    elseif not CalibrationEnabled then
        return
    else
        if calibration_npc == victim then
            local total_points = GetCalibrationScore()
            vINFO("Calibration NPC Killed!  It took " .. total_points .. " points to kill " .. calibration_vipd_npc.name)
            -- For more fine grained calibration, use damage taken by all players instead of points used
            calibration_vipd_npc.calibration = total_points
            InitNextCalibration()
        end
    end
end

function CalibrationPlayerDeath( victim, inflictor, attacker )
    if calibration_npc == nil then
        return
    elseif not CalibrationEnabled then
        return
    else
        total_deaths = total_deaths + 1
        AddPoints(victim, POINTS_INCREMENT * total_deaths)
    end
end

function CalibrationFailure()
    if CalibrationEnabled and calibration_vipd_npc ~= nil then
        if calibration_npc and calibration_npc:IsValid() then
            calibration_npc:Remove()
        end
        calibration_vipd_npc.enabled = false
        vINFO("Marking calibration of " .. calibration_vipd_npc.name .. " as a failure, and disabling the NPC.")
        InitNextCalibration()
    end
end

hook.Add( "OnNPCKilled", "VipdDefenseCalibrationNPCKilled", CalibrationNpcKilled)
hook.Add( "PlayerDeath", "VipdDefenseCalibrationPlayerDeath", CalibrationPlayerDeath)