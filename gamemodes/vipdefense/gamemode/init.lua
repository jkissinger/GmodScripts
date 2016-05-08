AddCSLuaFile ("config.lua")
AddCSLuaFile ("cl_init.lua")
AddCSLuaFile ("hud/client.lua")
AddCSLuaFile ("shared.lua")
AddCSLuaFile ("globals/client.lua")
AddCSLuaFile ("globals/shared.lua")

include ("logger.lua")
include ("shared.lua")
include ("experimental.lua")
include ("utils_sv.lua")

include ("globals/server.lua")
include ("globals/shared.lua")

include ("config/config.lua")
include ("config/custom_weapons_config.lua")
include ("config/custom_enemies_config.lua")
include ("config/settings.lua")

include ("hud/server.lua")

include ("spawn_system/ai.lua")
include ("spawn_system/init.lua")
include ("spawn_system/main.lua")
include ("spawn_system/spawn_logic.lua")
include ("spawn_system/spawn_npc.lua")

include ("level_system/main.lua")
include ("level_system/loadout.lua")
include ("level_system/weapon_store.lua")

include ("nodegraph/node_logic.lua")
include ("nodegraph/node_utils.lua")
include ("nodegraph/nodegraph.lua")

InitSystemGlobals ()

function GM:Initialize ()
    vINFO("Initializing VIP Defense")
    RunConsoleCommand ("sbox_noclip", "0")
    RunConsoleCommand ("sbox_godmode", "0")
    RunConsoleCommand ("sbox_playershurtplayers", "0")
    RunConsoleCommand ("sbox_weapons", "0")
    RunConsoleCommand ("ai_serverragdolls", "0")
    for k, weapon in pairs (vipd_weapons) do
        if weapon.tier > MaxTier then MaxTier = weapon.tier end
    end
    vDEBUG("Max weapon tier: "..MaxTier)
end

concommand.Add ("vipd_start", InitDefenseSystem, nil, "Initialize the VIP Defense gamemode")
concommand.Add ("vipd_stop", StopDefenseSystem, nil, "Stop the VIP Defense gamemode")
concommand.Add ("vipd_tp", Teleport, nil, "Teleport players")
concommand.Add ("vipd_tpold", TeleportToLastPos, nil, "Teleport player to a position shortly before they died")
concommand.Add ("vipd_freeze", FreezePlayers, nil, "Freeze players")
concommand.Add ("vipd_handicap", SetHandicap, nil, "Set players handicap")
concommand.Add ("vipd_buy", BuyWeapon, nil, "Buy a weapon")
