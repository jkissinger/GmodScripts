local total_nodes = 0
local spawn_system_nodes = { }
local last_team = nil
local last_node = nil
local last_team_count = 0

local function GetClosestValidNode()
    local closestKey = nil
    local closestDistance = MAX_DISTANCE
    local validDistance = false
    for k, node in pairs(vipd.Nodes) do
        local closestPlayer = GetClosestPlayer(node.pos, MAX_DISTANCE, MIN_SPAWN_DISTANCE)
        if closestPlayer then
            validDistance = true
            local playerDistance = MAX_DISTANCE
            for k, ply in pairs(player.GetAll()) do
                local distance = node.pos:Distance(ply:GetPos())
                if distance < playerDistance then
                    playerDistance = distance
                end
            end
            if playerDistance < closestDistance then
                closestKey = k
                closestDistance = playerDistance
            end
        end
    end
    if not closestKey then
        if validDistance then vWARN("No valid node found for no reason! Maybe there are no nodes: "..#vipd.Nodes)
        elseif not validDistance then vWARN("No valid node found with a valid distance!")
        end
    else
        local node = vipd.Nodes[closestKey]
        vDEBUG("Chose new init node @ "..tostring(node.pos).." which is "..closestDistance.." from the nearest player")
    end
    return vipd.Nodes[closestKey]
end

local function GetClosestUninitializedNode(last_node, nodes)
    local closest_node = nil
    local closest_distance = 0
    for k, node in pairs(nodes) do
        if not node.initialized then
            local distance = node.pos:Distance(last_node.pos)
            if distance < closest_distance or not closest_node then
                closest_node = node
                closest_distance = distance
            end
        end
    end
    return closest_node
end

local function FindNodeKey(nodes, node)
    for key, n in pairs(nodes) do
        if n.pos == node.pos then
            return key
        end
    end
    vWARN("Unknown node, unable to find key")
end

local function FinalizeNode(node)
    node.initialized = true
    table.insert(spawn_system_nodes, 1, node)
    local key = FindNodeKey(vipd.Nodes, node)
    table.remove(vipd.Nodes, key)
end

function InitializeNodes()
    local max_nodes = #spawn_system_nodes + NODES_PER_GROUP
    if #spawn_system_nodes == 0 then
        total_nodes = #vipd.Nodes
        local init_node = GetClosestValidNode()
        FinalizeNode(init_node)
    end
    while #vipd.Nodes > 0 and #spawn_system_nodes < max_nodes do
        local last_node = spawn_system_nodes[#spawn_system_nodes]
        local node = GetClosestUninitializedNode(last_node, last_node.neighbor)
        if not node then node = GetClosestUninitializedNode(last_node, vipd.Nodes) end
        vTRACE("Adding node @ " .. tostring(node.pos))
        FinalizeNode(node)
    end
    if #vipd.Nodes > 0 then
        timer.Simple(3, InitializeNodes)
        vINFO("Initialized "..#spawn_system_nodes.." nodes out of "..total_nodes)
    else
        TotalEnemies = #spawn_system_nodes
        vINFO("Finished initializing "..#spawn_system_nodes.." nodes.")
        vINFO("Registered Enemy Teams: " .. #vipd_enemy_teams)
        vINFO("Registered NPCs: " .. RegisteredNpcCount)
        vINFO("Registered Weapons: " .. RegisteredWeaponCount)
        MsgCenter("The Invasion has Begun!")
        DefenseSystem = true
    end
end

local function IsOutside(node)
    local trace = { }
    trace.start = node.pos
    trace.endpos = node.pos + Vector(0,0,MAX_DISTANCE)
    tr = util.TraceLine(trace)
    return tr.HitSky
end

local function HasFlyers(teamname)
    for k, enemy in pairs(vipd_npcs) do
        if enemy.teamname == teamname and enemy.flying then return true end
    end
    return false
end

local function IsTeamValidForNode(node, team)
    if team.disabled then return false end
    local air_node = node.type == 3
    if team.name == VipdAllyTeam.name then
        --Ally team is valid for all nodes except flying
        return not air_node
    end
    local node_is_outside = IsOutside(node)
    local valid_location = node_is_outside and team.outside or not node_is_outside and team.inside
    local max_enemy_value = CalculateMaxEnemyValue()
    if not valid_location then return false end
    for key, vipd_npc in pairs(GetNpcListByTeam(team)) do
        if vipd_npc.value <= max_enemy_value then
            if air_node and vipd_npc.flying or not air_node and not vipd_npc.flying then return true end
        end
    end
    return false
end

local function FindNextTeam(node)
    --configurable percent chance to spawn a group of allies
    local chance = math.random(100)
    if chance <= VIPD_ALLY_CHANCE and IsTeamValidForNode(node, VipdAllyTeam) then
        return VipdAllyTeam
    end
    local teams = { }
    for key, team in pairs(vipd_enemy_teams) do
        local team_equals_last_team = last_node and last_node.team and last_node.team.name == team.name
        if IsTeamValidForNode(node, team) and not team_equals_last_team then
            table.insert(teams, team)
        end
    end
    if #teams > 0 then
        last_team_count = 0
        local next_team = teams[math.random(#teams)]
        vDEBUG("Of "..#teams.." possible teams, chose: "..next_team.name)
        return next_team
    elseif last_node and last_node.team and IsTeamValidForNode(node, last_node.team) then
        vDEBUG("No new valid teams found, using last team: " .. last_node.team.name)
        last_team_count = last_team_count - 5
        return last_node.team
    else
        local nodetype = "Flying node"
        if node.type == 2 then nodetype = "Ground node" end
        local location = "inside"
        if IsOutside(node) then location = "outside" end
        vWARN("No valid team found for node! "..nodetype.." that is "..location)
    end
end

local function ChooseTeam(node)
    local within_range = last_node and node.pos:Distance(last_node.pos) < GROUP_DISTANCE
    if last_node and last_node.team and last_team_count < MAX_GROUP_SIZE and within_range and IsTeamValidForNode(node, last_node.team) then
        last_team_count = last_team_count + 1
        return last_node.team
    else
        return FindNextTeam(node)
    end
end

function RemainingNodeCount()
    return #spawn_system_nodes
end

function GetNextNode()
    local next_node = table.remove(spawn_system_nodes)
    if next_node == nil then
        vDEBUG("No nodes remaining!")
    else
        next_node.team = ChooseTeam(next_node)
        if next_node.team then
            vDEBUG("Returned next node (Team: "..next_node.team.name..") @ " .. tostring(next_node.pos))
        end
    end
    last_node = next_node
    return next_node
end
