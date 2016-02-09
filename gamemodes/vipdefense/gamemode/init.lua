AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
include("loadout.lua")
include("level_system.lua")
include("wave_system.lua")
include("vipd_utils.lua")
include("config.lua")
include("vipd_ai.lua")

-- Declare global vars
VIP = { }
vipName = "VIP"
vipMaxHealth = 100
waveNpcTable = { }
maxTier = 0
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
waveIsInProgress = false
currentWave = 1
currWaveValue = 0

function GM:Initialize()
    print("Initializing VIP Defense")
    RunConsoleCommand("sbox_noclip", "0")
    RunConsoleCommand("sbox_godmode", "0")
    RunConsoleCommand("sbox_playershurtplayers", "0")
    RunConsoleCommand("sbox_weapons", "0")
    for k, weapon in pairs(vipd_weapons) do
        if weapon.value > maxTier then maxTier = weapon.value end
    end
end