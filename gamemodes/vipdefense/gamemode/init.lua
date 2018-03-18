AddCSLuaFile("cl_init.lua")
AddCSLuaFile("hud/client.lua")
AddCSLuaFile("hud/store.lua")
AddCSLuaFile("hud/menu_bar.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("globals/client.lua")
AddCSLuaFile("globals/shared.lua")

include("logger.lua")
include("shared.lua")
include("experimental.lua")
include("utils_sv.lua")
include("think_handler.lua")
include("npc_calibration.lua")

include("globals/server.lua")
include("globals/shared.lua")

include("config/base_weapon_config.lua")
include("config/base_npc_config.lua")
include("config/custom_weapon_config.lua")
include("config/custom_npc_config.lua")
include("config/external_settings.lua")

include("hud/server.lua")

include("spawn_system/ai.lua")
include("spawn_system/init.lua")
include("spawn_system/main.lua")
include("spawn_system/spawn_logic.lua")
include("spawn_system/spawn_npc.lua")
include("spawn_system/think_handler.lua")
include("spawn_system/utils.lua")

include("level_system/main.lua")
include("level_system/loadout.lua")
include("level_system/weapon_store.lua")
include("level_system/points_handling.lua")
include("level_system/think_handler.lua")
include("level_system/init.lua")

include("nodegraph/node_utils.lua")
include("nodegraph/nodegraph.lua")

resource.AddFile("sound/vo/npc_anna_help.wav")
resource.AddFile("sound/vo/npc_elsa_help.wav")
resource.AddFile("sound/vo/npc_ironmangood_help.wav")

if not file.Exists( "vipdefense", "DATA" ) then file.CreateDir("vipdefense") end

function SetPlayerHurtPlayer()
    if PvpEnabled then
        RunConsoleCommand ("sbox_playershurtplayers", "1")
    else
        RunConsoleCommand ("sbox_playershurtplayers", "0")
    end
end

function GM:Initialize()
    vINFO("Initializing VIP Defense")
    RunConsoleCommand ("sbox_noclip", "0")
    RunConsoleCommand ("sbox_godmode", "0")
    SetPlayerHurtPlayer()
    RunConsoleCommand ("sbox_weapons", "0")
    InitializeLevelSystem()
    InitializeSpawnSystem()
end

concommand.Add("vipd_start", StartDefenseSystem, nil, "Initialize the VIP Defense gamemode")
concommand.Add("vipd_stop", StopDefenseSystem, nil, "Stop the VIP Defense gamemode")
concommand.Add("vipd_start_calibration", StartNpcCalibration, nil, "Initialize NPC calibration")
concommand.Add("vipd_stop_calibration", StopNpcCalibration, nil, "Stop NPC calibration")
concommand.Add("vipd_tp", Teleport, nil, "Teleport players")
concommand.Add("vipd_tpold", TeleportToLastPos, nil, "Teleport player to a position shortly before they died")
concommand.Add("vipd_freeze", FreezePlayers, nil, "Freeze players")
concommand.Add("vipd_handicap", SetHandicap, nil, "Set players handicap")
concommand.Add("vipd_buy", BuyWeapon, nil, "Buy a weapon")
concommand.Add("vipd_givepoints", GivePoints, nil, "Give a player points")
concommand.Add("vipd_pvp", PvpToggle, nil, "Toggle PVP mode")
concommand.Add("vipd_tpall", TeleportAll, nil, "Teleport all players to you")
