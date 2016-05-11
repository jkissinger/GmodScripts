local function LogNodeCounts()
    local nodetypes = { }
    for k, node in pairs(vipd_nodegraph.nodes) do
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
    if #vipd.Nodes > 0 then vINFO(msg) end
    local unusedNodes = #vipd_nodegraph.nodes - #vipd.Nodes
    vDEBUG("Total Nodes " .. #vipd.Nodes .. " Unused: "..unusedNodes)
end

local function LogTeamCounts()
    local teams = { }
    for k, node in pairs(vipd.Nodes) do
        if not teams[node.team] then
            teams[node.team] = 1
        else
            teams[node.team] = teams[node.team] + 1
        end
    end
    local msg = "Team Counts - "
    for teamname, count in pairs(teams) do
        msg = msg..teamname..": "..count.." "
        if teamname == VipdFriendlyTeam then TotalFriendlys = count end
    end
    TotalEnemies = #vipd.Nodes - TotalFriendlys
    if #vipd.Nodes > 0 then vINFO(msg) end
end

local function FindNodeKey(nodes, node)
    for key, n in pairs(nodes) do
        if n == node then return key end
    end
    for key, n in pairs(nodes) do
        if n.pos == node.pos then
            vWARN("Unknown node found by pos only")
            return key
        end
    end
end

local function AddNode(nodes, node)
    local key = FindNodeKey(nodes, node)
    if not key then
        table.insert(nodes, node)
    else
    --vWARN("Unable to add node, already exists!")
    end
    return not key
end

local function RemoveNode(nodes, node)
    local key = FindNodeKey(nodes, node)
    if key then return table.remove(nodes, key) end
end

function AddNodeIfValid(nodes, node)
    if not node.used and AddNode(nodes, node) then
        return true
    end
end

function AddNextNode(node)
    if AddNodeIfValid(NextNodes, node) then
        node.used = true
        if not AddNode(UsedNodes, node) then
            vERROR("Unable to add used node, fatal error!")
        end
        if not RemoveNode(vipd.Nodes, node) then
            --BUG: This happens occasionally on certain maps and causes the server to crash, need to figure out why
            vWARN("Unable to remove node: "..tostring(node.pos)..", fatal error!")
        end
        return true
    end
end

local function CheckForDupes(nodes)
    for key, node in pairs(nodes) do
        local fkey = FindNodeKey(nodes, node)
        if key ~= fkey then
            --This may not matter anymore because we're no longer using pos for node equality
            vINFO("Duplicate node found. Key:"..key)
            vDEBUG("Removing duplicate node "..tostring(node.pos))
            table.remove(nodes, fkey)
        end
    end
end

function GetNodes()
    vipd_nodegraph = GetVipdNodegraph()
    if not vipd_nodegraph then
        vDEBUG("No vipd_nodegraph found")
        return
    end
    local nodes = vipd_nodegraph.nodes
    if not nodes then
        vDEBUG("No nodes found in graph")
        return
    end
    CheckForDupes(nodes)
    zones = { }
    vDEBUG("Nodes: " .. #nodes)
    for k, node in pairs(nodes) do
        if node.type == 2 or node.type == 3 then
            chance = math.random(10)
            if chance == 1 then
                node.team = VipdFriendlyTeam
                table.insert(vipd.Nodes, node)
            else
                SetNodeTeam(node, false)
                if node.team then table.insert(vipd.Nodes, node) end
            end
            if node.team then node.used = false end
        end
    end
    LogNodeCounts()
    LogTeamCounts()
end

local function isOutside(node)
    local trace = { }
    trace.start = node.pos
    trace.endpos = node.pos + Vector(0,0,MaxDistance)
    tr = util.TraceLine(trace)
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
        vWARN("No valid team found for node! "..nodetype.." that is "..location)
    end
end

function SetNodeTeam(node, assimilate)
    if not node.team then
        local team = ChooseTeam(node)
        if not team then return end
        local mismatch = false
        for k, neighbor in pairs(node.neighbor) do
            if neighbor.team and neighbor.team ~= team and neighbor.team ~= VipdFriendlyTeam and assimilate then
                mismatch = false
                team = neighbor.team
            elseif neighbor.team and neighbor.team ~= team and neighbor.team ~= VipdFriendlyTeam then
                mismatch = true
            elseif neighbor.team and neighbor.team ~= VipdFriendlyTeam and mismatch then
                mismatch = false
                team = neighbor.team
            elseif mismatch then
                team = SetNodeTeam(neighbor, true)
            else
                neighbor.team = team
            end
        end
        node.team = team
        return team
    end
end
