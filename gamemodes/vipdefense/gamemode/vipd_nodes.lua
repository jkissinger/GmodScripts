local function PosVisible (start, endpos, player)
    local trace = { }
    trace.start = start
    trace.endpos = endpos
    trace.filter = player
    tr = util.TraceLine (trace)
    return (not tr.Hit)
end

local function PosValidDistance (ply, pos)
    local distance = pos:Distance (ply:GetPos ())
    return distance > minSpawnDistance
end

function IsNodeValid (node)
    local Offset = Vector (0, 0, 10)
    local result = true
    for k, ply in pairs (player.GetAll ()) do
        --test node visibility, we don't want to spawn where players can see it
        result = result and not PosVisible (node.pos, ply:EyePos (), ply)
        result = result and not PosVisible (node.pos + Offset, ply:EyePos (), ply)
        --test spawn distance
        result = result and PosValidDistance (ply, node.pos)
    end
    return result
end

function GetNodes ()
    nodegraph = GetNodeGraph ()
    local nodes = nodegraph.nodes
    zones = { }
    VipdLog (vDEBUG, "Nodes: " .. #nodes)
    for k, node in pairs (nodes) do
        if node.type == 2 or node.type == 3 then
            chance = math.random (10)
            if chance == 1 then
                table.insert (vipd.CitizenNodes, node)
            else
                SetNodeTeam (node, false)
                table.insert (vipd.EnemyNodes, node)
            end
        end
    end
    local unusedNodes = #nodes - #vipd.EnemyNodes - #vipd.CitizenNodes
    VipdLog (vDEBUG, "Enemy Nodes " .. #vipd.EnemyNodes .. " Citizen Nodes: " .. #vipd.CitizenNodes.." Unused: "..unusedNodes)
    CountTeams()
end

function CountTeams()
    local Zombies = 0
    local Overwatch = 0
    local Antlions = 0
    local Other = 0
    for k, node in pairs(vipd.EnemyNodes) do
        if node.team == "Zombies" then
            Zombies = Zombies + 1
        elseif node.team == "Overwatch" then
            Overwatch = Overwatch + 1
        elseif node.team == "Antlions" then
            Antlions = Antlions + 1
            else 
            Other = Other + 1
        end
    end
    VipdLog(vINFO, "Zombies: "..Zombies.." Overwatch: "..Overwatch.." Antlions: "..Antlions.." Other: "..Other)
end

local function isOutside(node)
    local trace = { }
    trace.start = node.pos
    trace.endpos = node.pos + Vector(0,0,5000)
    tr = util.TraceLine (trace)
    return tr.HitSky
end

local function ChooseTeam(node)
    local IsOutside = isOutside(node)
    local teams = { }
    for k, team in pairs(vipd_enemy_teams) do
        if (IsOutside and team.outside) or (not IsOutside and team.inside) then
            table.insert(teams, team)
        end
    end
    return teams[math.random(#teams)].name
end

function SetNodeTeam (node, assimilate)
    if not node.team then
        local team = ChooseTeam(node)
        local mismatch = false
        for k, neighbor in pairs(node.neighbor) do
            if neighbor.team and neighbor.team ~= team and assimilate then
                mismatch = false
                team = neighbor.team
            elseif neighbor.team and neighbor.team ~= team then
                mismatch = true
            elseif neighbor.team and mismatch then
                mismatch = false
                team = neighbor.team
            elseif mismatch then
                team = SetNodeTeam (neighbor, true)
                else
                neighbor.team = team
            end
        end
        node.team = team
        return team
    end
end




