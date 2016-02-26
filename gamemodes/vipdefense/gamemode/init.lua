AddCSLuaFile ("cl_init.lua")
AddCSLuaFile ("shared.lua")

include ("shared.lua")
include ("loadout.lua")
include ("level_system.lua")
include ("defense_system.lua")
include ("sv_vipd_utils.lua")
include ("config.lua")
include ("vipd_hud.lua")
include ("vipd_ai.lua")
include ("vipd_nodes.lua")
include ("vipd_nodegraph.lua")
include ("experimental.lua")

-- Declare global vars
MaxLevel = 100
MaxTier = 0
-- Minimum distance to spawn from players
minSpawnDistance = 800
-- Global wave system variables
MaxNpcs = 60
MaxDistance = 500000
EnemiesPerPlayer = 20
CitizensPerPlayer = 5
CitizenPointValue = 10
vTRACE = { name = "TRACE: ", value = 0 }
vDEBUG = { name = "DEBUG: ", value = 1 }
vINFO = { name = "INFO: ", value = 2 }
vWARN = { name = "WARN: ", value = 3 }
vERROR = { name = "ERROR: ", value = 4 }
VipdLogLevel = vDEBUG

function InitSystemGlobals ()
    vipd = { }
    vipd.Players = { }
    vipd.EnemyNodes = { }
    vipd.CitizenNodes = { }
    vipd.Vips = { }
    currentEnemies = 0
    currentCitizens = 0

    --TODO: add hook to trigger this when the convar pointsperlevel changes
    LevelTable = { }
    for i=1, MaxLevel, 1 do
        local base = GetLevelInterval () * i
        local modifier = GetLevelInterval () * 0.2
        local levelBase = i * i * modifier
        local points = math.floor (base + levelBase)
        table.insert (LevelTable, points)
    end
end

InitSystemGlobals ()

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
            else
                print (level.name .. msg)
            end
        end
    end
end

concommand.Add ("vipd_start", InitDefenseSystem, nil, "Initialize the VIP Defense gamemode")
concommand.Add ("vipd_stop", StopDefenseSystem, nil, "Stop the VIP Defense gamemode")
concommand.Add ("vipd_navmesh", GenerateNavmesh, nil, "Generate a new navmesh")
concommand.Add ("vipd_tp", Teleport, nil, "Teleport players")
concommand.Add ("vipd_printnpcs", PrintNPCs, nil, "Print list of NPCs to the console")
concommand.Add ("vipd_freeze", FreezePlayers, nil, "Freeze players")