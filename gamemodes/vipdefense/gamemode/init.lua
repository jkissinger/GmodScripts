AddCSLuaFile("config.lua")
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

include("globals/server.lua")
include("globals/shared.lua")

include("config/config.lua")
include("config/custom_weapons_config.lua")
include("config/custom_enemies_config.lua")
include("config/settings.lua")

include("hud/server.lua")

include("spawn_system/ai.lua")
include("spawn_system/init.lua")
include("spawn_system/main.lua")
include("spawn_system/spawn_logic.lua")
include("spawn_system/spawn_npc.lua")

include("level_system/main.lua")
include("level_system/loadout.lua")
include("level_system/weapon_store.lua")
include("level_system/points_handling.lua")

include("nodegraph/node_logic.lua")
include("nodegraph/node_utils.lua")
include("nodegraph/nodegraph.lua")

InitSystemGlobals()

local function GetDataFromGmod(vipd_weapon)
    local class = vipd_weapon.class
    local swep = weapons.Get( class )
    if swep == nil then
        swep = list.Get("Weapon")[class]
    end
    if swep == nil then
        swep = list.Get("SpawnableEntities")[name]
    end
    if swep == nil then
        vDEBUG("Could not find "..class.." in gmod's list.")
    else
        vipd_weapon.name = swep.PrintName
        if swep.Primary then vipd_weapon.primary_ammo = swep.Primary.Ammo end
        if swep.Secondary then vipd_weapon.secondary_ammo = swep.Secondary.Ammo end
    end
    if not vipd_weapon.name then vipd_weapon.name = class end
end

function GM:Initialize()
    vINFO("Initializing VIP Defense")
    RunConsoleCommand ("sbox_noclip", "0")
    RunConsoleCommand ("sbox_godmode", "0")
    if not PVP_ENABLED:GetBool() then
        RunConsoleCommand ("sbox_playershurtplayers", "0")
    else
        RunConsoleCommand ("sbox_playershurtplayers", "1")
    end
    RunConsoleCommand ("sbox_weapons", "0")
    RunConsoleCommand ("ai_serverragdolls", "0")
    for class, vipd_weapon in pairs(vipd_weapons) do
        if not vipd_weapon.cost then vipd_weapon.cost = 0 end
        if not vipd_weapon.npcValue then vipd_weapon.npcValue = 0 end
        if not vipd_weapon.tier then vipd_weapon.tier = 0 end
        if not vipd_weapon.class then vipd_weapon.class = class end
        if not vipd_weapon.max_permanent then vipd_weapon.max_permanent = 1 end
        GetDataFromGmod(vipd_weapon)
    end
    for k, weapon in pairs(vipd_weapons) do
        if weapon.tier > MaxTier then MaxTier = weapon.tier end
    end
    vDEBUG("Max weapon tier: "..MaxTier)
end

concommand.Add("vipd_start", InitDefenseSystem, nil, "Initialize the VIP Defense gamemode")
concommand.Add("vipd_stop", StopDefenseSystem, nil, "Stop the VIP Defense gamemode")
concommand.Add("vipd_tp", Teleport, nil, "Teleport players")
concommand.Add("vipd_tpold", TeleportToLastPos, nil, "Teleport player to a position shortly before they died")
concommand.Add("vipd_freeze", FreezePlayers, nil, "Freeze players")
concommand.Add("vipd_handicap", SetHandicap, nil, "Set players handicap")
concommand.Add("vipd_buy", BuyWeapon, nil, "Buy a weapon")
concommand.Add("vipd_givepoints", GivePoints, nil, "Give a player points")
concommand.Add("vipd_tpall", TeleportAll, nil, "Teleport all players to you")
