AddCSLuaFile ("cl_init.lua")
AddCSLuaFile ("shared.lua")
AddCSLuaFile ("sh_vipd_utils.lua")

include ("shared.lua")
include ("sh_vipd_utils.lua")
include ("loadout.lua")
include ("level_system.lua")
include ("wave_system.lua")
include ("sv_vipd_utils.lua")
include ("config.lua")
include ("vipd_ai.lua")
include ("vipd_nodegraph.lua")
include ("experimental.lua")


-- Declare global vars
VIP = { }
VipName = "VIP"
VipMaxHealth = 100
WaveEnemyTable = { }
MaxTier = 0
-- Minimum distance to spawn from the VIP
minSpawnDist = 500
-- Maximum distance to spawn from the VIP
maxSpawnDist = 2500
-- Global wave system variables
WaveIsInProgress = false
CurrentWave = 1
CurrentWaveValue = 0
TimeBetweenWaves = 15
WaveSystemPaused = false
vTRACE = { name = "TRACE: ", value = 0 }
vDEBUG = { name = "DEBUG: ", value = 1 }
vINFO = { name = "INFO: ", value = 2 }
vWARN = { name = "WARN: ", value = 3 }
vERROR = { name = "ERROR: ", value = 4 }
VipdLogLevel = vDEBUG
vipd = { }
vipd.nodes = { }
vipd.enemies = { }
vipd.citizens = { }
vipd.vips = { }

function GM:Initialize ()
    VipdLog (vINFO, "Initializing VIP Defense")
    RunConsoleCommand ("sbox_noclip", "0")
    RunConsoleCommand ("sbox_godmode", "0")
    RunConsoleCommand ("sbox_playershurtplayers", "0")
    RunConsoleCommand ("sbox_weapons", "0")
    for k, weapon in pairs (vipd_weapons) do
        if weapon.value > MaxTier then MaxTier = weapon.value end
    end
    team.SetUp (1, "VIPD", Color (0, 0, 255), true)
end

function VipdLog (level, msg)
    if level.value >= VipdLogLevel.value then
        if type (msg) == "table" then
            print (level.name .. " Table:")
            PrintTable (msg)
        else
            if level.value >= vINFO.value then
                if level.value >= vERROR.value then
                    BroadcastError (level.name .. msg)
                else
                    BroadcastNotify (level.name .. msg)
                end
            end
            print (level.name .. msg)
        end
    end
end

concommand.Add ("vipd_start", InitWaveSystem, nil, "Initialize the VIP Defense Wave System")
concommand.Add ("vipd_pause", PauseWaveSystem, nil, "Pause the wave system after the current wave ends")
concommand.Add ("vipd_navmesh", GenerateNavmesh, nil, "Generate a new navmesh")
concommand.Add ("vipd_aitest", AITest, nil, "Test AI functionality on a map")
concommand.Add ("vipd_nodetest", PrintNodeGraphs, nil, "Experimenting with nodes")