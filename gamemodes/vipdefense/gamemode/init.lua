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

include("globals/server.lua")
include("globals/shared.lua")

include("config/base_weapon_config.lua")
include("config/base_npc_config.lua")
include("config/custom_weapon_config.lua")
include("config/custom_npc_config.lua")
include("config/settings.lua")

include("hud/server.lua")

include("spawn_system/ai.lua")
include("spawn_system/init.lua")
include("spawn_system/main.lua")
include("spawn_system/spawn_logic.lua")
include("spawn_system/spawn_npc.lua")
include("spawn_system/think_handler.lua")

include("level_system/main.lua")
include("level_system/loadout.lua")
include("level_system/weapon_store.lua")
include("level_system/points_handling.lua")
include("level_system/think_handler.lua")

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
    if swep ~= nil then
        vipd_weapon.name = swep.PrintName
        if swep.Primary then vipd_weapon.primary_ammo = swep.Primary.Ammo end
        if swep.Secondary then vipd_weapon.secondary_ammo = swep.Secondary.Ammo end
    end
    if not vipd_weapon.name then vipd_weapon.name = class end
end

local function GetMinWeaponValue(classname)
    local min_value = 1000
    local npc = list.Get("NPC")[classname]
    if npc and npc.Weapons then
        for key, weapon in pairs(npc.Weapons) do
            local vipd_weapon = vipd_weapons[weapon]
            if vipd_weapon then
                if vipd_weapon.npcValue < min_value then min_value = vipd_weapon.npcValue end
            else
                vDEBUG(classname .. " uses unknown weapon " .. weapon)
            end
        end
    end
    if min_value == 1000 then min_value = 0 end
    return min_value
end

local function GetMinTeamValue(teamname)
    local minValue = 1000
    for key, npc in pairs(vipd_npcs) do
        local min_weapon_value = GetMinWeaponValue(npc.gmod_class)
        local value = npc.value + min_weapon_value
        if npc.teamname == teamname and minValue > value then
            minValue = value
        end
    end
    vDEBUG("Found min value " .. minValue .. " for team " .. teamname)
    return minValue
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
        RegisteredWeaponCount = RegisteredWeaponCount + 1
        if not vipd_weapon.cost then vipd_weapon.cost = 0 end
        if not vipd_weapon.npcValue then vipd_weapon.npcValue = 0 end
        if not vipd_weapon.tier then vipd_weapon.tier = 0 end
        if not vipd_weapon.class then vipd_weapon.class = class end
        if not vipd_weapon.max_permanent then vipd_weapon.max_permanent = 1 end
        GetDataFromGmod(vipd_weapon)
        if vipd_weapon.tier > MaxTier then MaxTier = vipd_weapon.tier end
    end
    for k, team in pairs(vipd_enemy_teams) do
        team.min_value = GetMinTeamValue(team.name)
    end
    for key, npc in pairs(vipd_npcs) do
        RegisteredNpcCount = RegisteredNpcCount + 1
        npc.gmod_class = key
        npc.class = key
        local gmod_npc = list.Get("NPC")[key]
        if gmod_npc then
            if gmod_npc.Class then npc.class = gmod_npc.Class end
            if gmod_npc.Name then npc.name = gmod_npc.Name end
            if gmod_npc.Model then NpcsByModel[gmod_npc.Model] = { name = npc.name, value = npc.value } end
        end
    end
    vDEBUG("Max weapon tier: "..MaxTier)
    PrintWeapons()
    PrintNPCS()
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
