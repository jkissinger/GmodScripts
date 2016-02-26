local function LogNodeCounts()
    local nodetypes = { }
    for k, node in pairs(nodegraph.nodes) do
        if not nodetypes[node.type] then
            nodetypes[node.type] = 1
        else
            nodetypes[node.type] = nodetypes[node.type] + 1
        end
    end
    local msg = "Node Types - "
    for type, count in pairs(nodetypes) do
        msg = msg.."Type "..type..": "..count.." "
    end
    if #vipd.EnemyNodes > 0 then VipdLog(vINFO, msg) end
    local unusedNodes = #nodegraph.nodes - #vipd.EnemyNodes - #vipd.CitizenNodes
    VipdLog (vDEBUG, "Enemy Nodes " .. #vipd.EnemyNodes .. " Citizen Nodes: " .. #vipd.CitizenNodes.." Unused: "..unusedNodes)
end

local function LogTeamCounts()
    local teams = { }
    for k, node in pairs(vipd.EnemyNodes) do
        if not teams[node.team] then
            teams[node.team] = 1
        else
            teams[node.team] = teams[node.team] + 1
        end
    end
    local msg = "Enemy Team Counts - "
    for teamname, count in pairs(teams) do
        msg = msg..teamname..": "..count.." "
    end
    if #vipd.EnemyNodes > 0 then VipdLog(vINFO, msg) end
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
                if node.team then table.insert (vipd.EnemyNodes, node) end
            end
        end
    end
    LogNodeCounts()
    LogTeamCounts()
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
    if #teams > 0 then
        return teams[math.random(#teams)].name
    else
        local nodetype = "Flying node"
        if node.type == 2 then nodetype = "Ground node" end
        local location = "inside"
        if IsOutside then location = "outside" end
        VipdLog(vWARN, "No valid team found for node! "..nodetype.." that is "..location)
    end
end

function SetNodeTeam (node, assimilate)
    if not node.team then
        local team = ChooseTeam(node)
        if not team then return end
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
