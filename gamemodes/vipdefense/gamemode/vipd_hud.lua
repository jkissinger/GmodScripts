--Thinking
function VipdHudUpdate ()
    local Players = { }
    for k, ply in pairs (player.GetAll ()) do
        local p = { }
        p.points = GetPoints (ply)
        p.level = GetLevel (ply)
        p.grade = GetGrade (ply)
        Players[ply:Name ()] = p
    end
    netTable = {
        ["EnemiesLeft"] = #vipd.EnemyNodes + currentEnemies,
        ["CitizensLeft"] = #vipd.CitizenNodes + currentCitizens,
        ["VipName"] = VipName,
        ["ActiveSystem"] = DefenseSystem,
        ["VipdPlayers"] = Players
    }
    UpdateClientHud (netTable)
end

util.AddNetworkString ("vipd_hud")

function UpdateClientHud (netTable)
    net.Start ("vipd_hud")
    net.WriteTable (netTable)
    net.Broadcast ()
end

hook.Add ("Think", "Update the vipd hud", VipdHudUpdate)