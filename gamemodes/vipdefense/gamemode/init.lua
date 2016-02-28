AddCSLuaFile ("cl_init.lua")
AddCSLuaFile ("hud_cl.lua")
AddCSLuaFile ("shared.lua")

include ("ai.lua")
include ("config.lua")
include ("defense_system.lua")
include ("experimental.lua")
include ("hud_sv.lua")
include ("level_system.lua")
include ("loadout.lua")
include ("node_logic.lua")
include ("node_utils.lua")
include ("nodegraph.lua")
include ("shared.lua")
include ("spawn_logic.lua")
include ("spawn_npc.lua")
include ("utils_sv.lua")


-- Declare global vars
MaxLevel = 100
MaxTier = 0
-- Minimum distance to spawn from players
minSpawnDistance = 800
-- Global wave system variables
MaxNpcs = 50
MaxDistance = 500000
NpcsPerPlayer = 20
FriendlyPointValue = 10
vTRACE = { name = "TRACE: ", value = 0 }
vDEBUG = { name = "DEBUG: ", value = 1 }
vINFO = { name = "INFO: ", value = 2 }
vWARN = { name = "WARN: ", value = 3 }
vERROR = { name = "ERROR: ", value = 4 }
VipdLogLevel = vDEBUG
local Timestamp = os.time()
LogFile = "log-"..os.date( "%Y-%m-%d" , Timestamp )..".txt"

function InitSystemGlobals ()
    vipd = { }
    vipd.Players = { }
    vipd.Nodes = { }
    --These have to be global cause they're used by the HUD, even if the defense system is inactive
    currentNpcs = 0
    TotalFriendlys = 0
    totalEnemies = 0
    DeadFriendlys = 0
    RescuedFriendlys = 0
    deadEnemies = 0

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
        file.Append( "helloworld.txt", "Append1!" )
        if type (msg) == "table" then
            print (level.name .. " Table:")
            PrintTable (msg)
        else
            msg = level.name..msg
            if level.value >= vINFO.value then
                if level.value >= vERROR.value then
                    BroadcastError (msg)
                    if DefenseSystem then StopDefenseSystem() end
                else
                    BroadcastNotify (msg)
                end
            else
                print (msg)
            end
            file.Append( LogFile, msg.."\n")
        end
    end
end

concommand.Add ("vipd_start", InitDefenseSystem, nil, "Initialize the VIP Defense gamemode")
concommand.Add ("vipd_stop", StopDefenseSystem, nil, "Stop the VIP Defense gamemode")
concommand.Add ("vipd_navmesh", GenerateNavmesh, nil, "Generate a new navmesh")
concommand.Add ("vipd_tp", Teleport, nil, "Teleport players")
concommand.Add ("vipd_printnpcs", PrintNPCs, nil, "Print list of NPCs to the console")
concommand.Add ("vipd_freeze", FreezePlayers, nil, "Freeze players")
concommand.Add ("vipd_handicap", SetHandicap, nil, "Set players handicap")
