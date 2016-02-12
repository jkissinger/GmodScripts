AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("sh_vipd_utils.lua")

include("shared.lua")
include("sh_vipd_utils.lua")
include("loadout.lua")
include("level_system.lua")
include("wave_system.lua")
include("sv_vipd_utils.lua")
include("config.lua")
include("vipd_ai.lua")

-- Declare global vars
VIP = { }
VipName = "VIP"
VipMaxHealth = 100
WaveEnemyTable = { }
MaxTier = 0
-- If closer than this patrol no matter what
minPatrolDist = 200
-- If not moving < than this then patrol
-- If moving, keep doing whatever
maxPatrolDist = 400
-- Minimum distance to spawn from the VIP
minSpawnDist = 200
-- Maximum distance to spawn from the VIP
maxSpawnDist = 2000
-- Global wave system variables
WaveIsInProgress = false
CurrentWave = 1
CurrentWaveValue = 0
TimeBetweenWaves = 10

function GM:Initialize()
    print("Initializing VIP Defense")
    RunConsoleCommand("sbox_noclip", "0")
    RunConsoleCommand("sbox_godmode", "0")
    RunConsoleCommand("sbox_playershurtplayers", "0")
    RunConsoleCommand("sbox_weapons", "0")
    for k, weapon in pairs(vipd_weapons) do
        if weapon.value > MaxTier then MaxTier = weapon.value end
    end
end