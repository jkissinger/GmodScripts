util.AddNetworkString ("vipd_hud")

local function UpdateClientHud (netTable)
    net.Start ("vipd_hud")
    net.WriteTable (netTable)
    net.Broadcast ()
end

local function VipdHudUpdate ()
    local Players = { }
    for k, ply in pairs (player.GetAll ()) do
        local p = { }
        p.points = GetPoints (ply)
        p.level = GetLevel (ply)
        p.grade = GetGrade (ply)
        Players[ply:Name ()] = p
    end
    netTable = {
        ["EnemiesLeft"] = TotalEnemies - DeadEnemies,
        ["TotalFriendlys"] = TotalFriendlys,
        ["DeadFriendlys"] = DeadFriendlys,
        ["RescuedFriendlys"] = RescuedFriendlys,
        ["VipName"] = VipName,
        ["ActiveSystem"] = DefenseSystem,
        ["VipdPlayers"] = Players
    }
    UpdateClientHud (netTable)
end

hook.Add ("Think", "Update the vipd hud", VipdHudUpdate)
