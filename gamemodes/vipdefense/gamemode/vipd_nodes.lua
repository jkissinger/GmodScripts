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
        --Disabled below line, possible performance improvement?
        --result = result and not PosVisible (node.pos, ply:EyePos (), ply)
        result = result and not PosVisible (node.pos + Offset, ply:EyePos (), ply)
        --test spawn distance
        result = result and PosValidDistance (ply, node.pos)
    end
    result = result and (GetMaxEnemyValue() >= GetMinTeamValue(node.team) or node.team == VipdPlayerTeam)
    return result
end

function GetNodes ()
    nodegraph = GetNodeGraph ()
    if not nodegraph then return end
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
    LogTeamCounts()
end

function LogTeamCounts()
    local teams = { }
    for k, node in pairs(vipd.EnemyNodes) do
        if not teams[node.team] then
            teams[node.team] = 1
        else
            teams[node.team] = teams[node.team] + 1
        end
    end
    local msg = ""
    for teamname, count in pairs(teams) do
        msg = msg..teamname..": "..count.." "
    end
    if #vipd.EnemyNodes > 0 then VipdLog(vINFO, msg) end
end

local function isOutside(node)
    local trace = { }
    trace.start = node.pos
    trace.endpos = node.pos + Vector(0,0,MaxDistance)
    tr = util.TraceLine (trace)
    return tr.HitSky
end

local function HasFlyers(teamName)
    for k, enemy in pairs(vipd_npcs) do
        if enemy.team == teamName and enemy.flying then return true end
    end
    return false
end

local function ChooseTeam(node)
    local IsOutside = isOutside(node)
    local teams = { }
    for k, team in pairs(vipd_enemy_teams) do
        local validFlyingNode = node.type ~= 3 or node.type == 3 and HasFlyers(team.name)
        local validOutsideTeam = IsOutside and team.outside
        local validInsideTeam = not IsOutside and team.inside
        if validFlyingNode and (validOutsideTeam or validInsideTeam) then
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
