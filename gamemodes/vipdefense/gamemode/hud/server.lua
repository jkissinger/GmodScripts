util.AddNetworkString ("vipd_hud_init")
util.AddNetworkString ("vipd_hud")
util.AddNetworkString ("vipd_menu")

function VipdHudInit (netTable)
    net.Start ("vipd_hud_init")
    net.WriteTable (netTable)
    net.Broadcast ()
end

local function UpdateClientHud (netTable)
    net.Start ("vipd_hud")
    net.WriteTable (netTable)
    net.Broadcast ()
end

local function VipdHudUpdate ()
    local enemy_display = currentNpcs
    if currentNpcs == 0 then enemy_display = TotalEnemies - DeadEnemies end
    local Players = { }
    for k, ply in pairs (player.GetAll ()) do
        local p = { }
        p.points = GetAvailablePoints (ply)
        p.level = GetLevel (ply)
        p.grade = GetGrade (ply)
        p.weapons = GetVply(ply:Name()).weapons
        Players[ply:Name ()] = p
    end
    netTable = {
        ["EnemiesLeft"] = enemy_display,
        ["TotalFriendlys"] = TotalFriendlys,
        ["DeadFriendlys"] = DeadFriendlys,
        ["RescuedFriendlys"] = RescuedFriendlys,
        ["VipName"] = VipName,
        ["ActiveSystem"] = DefenseSystem,
        ["VipdPlayers"] = Players,
        ["VipdWeapons"] = Weapons
    }
    UpdateClientHud (netTable)
end

hook.Add ("Think", "Update the vipd hud", VipdHudUpdate)
