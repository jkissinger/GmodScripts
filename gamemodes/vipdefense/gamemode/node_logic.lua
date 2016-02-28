local function CountConnectedNodes(nodes)
    local numNodes = #nodes
    local added = false
    for key, node in pairs(nodes) do
        if not node.Counted then
            node.Counted = true
            for key, neighbor in pairs(node.neighbor) do
                if not neighbor.Counted then
                    if AddNodeIfValid(nodes, neighbor) then added = true end
                end
            end
        end
    end
    if numNodes == 1 then
        local firstNode = table.remove(nodes, 1)
        AddNodeIfValid(nodes, firstNode)
    end

    if added then
        return CountConnectedNodes(nodes)
    else
        return #nodes
    end
end

local function ResetNodeStatus()
    for k, node in pairs(vipd.Nodes) do
        node.Counted = false
    end
end

local function FindNextInitNode(nodes, remove)
    --Iterate through all nodes in next nodes and count their connected nodes
    local count = 0
    local nextInitNode = nil
    for key, node in pairs(nodes) do
        local connectedNodes = { }
        table.insert(connectedNodes, node)
        local numConnectedNodes = CountConnectedNodes(connectedNodes)
        VipdLog(vTRACE, "Node "..key.." had "..numConnectedNodes.." connected nodes and "..#node.neighbor.." neighbors")
        ResetNodeStatus()
        if numConnectedNodes == 0 then
            if remove then
                VipdLog(vTRACE, "Removing node "..key.." from table because it has no connected nodes")
                table.remove(nodes, key)
            end
        elseif numConnectedNodes < count or count == 0 then
            count = numConnectedNodes
            nextInitNode = node
        end
    end
    if nextInitNode then
        NextNodes.InitNode = nextInitNode
        VipdLog(vDEBUG, "Next init node has "..count.." valid connected nodes and is @ "..tostring(nextInitNode.pos))
    else
        VipdLog(vDEBUG, "Unable to find next init node with remove: "..tostring(remove))
    end
    return nextInitNode
end

local function GetMinTeamValue(teamName)
    local minValue = 1000
    for k, npc in pairs(vipd_npcs) do
        --Assume NPC uses weapon with value of 1
        local value = npc.value + 1
        if npc.team == teamName and minValue > value then
            minValue = value
        end
    end
    return minValue
end

local function GetClosestValidNode()
    local closestKey = nil
    local closestDistance = MaxDistance
    local validDistance = false
    local validValue = false
    for k, node in pairs(vipd.Nodes) do
        local closestPlayer = GetClosestPlayer(node.pos, MaxDistance, minSpawnDistance)
        if closestPlayer then
            validDistance = true
            if GetMaxEnemyValue() >= GetMinTeamValue(node.team) or node.team == VipdFriendlyTeam then
                validValue = true
                local playerDistance = MaxDistance
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
    end
    if not closestKey then
        if validDistance and validValue then VipdLog(vWARN, "No valid node found for no reason! Maybe there are no nodes: "..#vipd.Nodes)
        elseif validDistance and not validValue then VipdLog(vWARN, "No valid node found because there were no nodes with a valid value!")
        elseif not validDistance then VipdLog(vWARN, "No valid node found with a valid distance!")
        end
    else
        local node = vipd.Nodes[closestKey]
        VipdLog(vDEBUG, "Chose new init node @ "..tostring(node.pos).." which is "..closestDistance.." from the nearest player")
    end
    return vipd.Nodes[closestKey]
end

local function SetupNextNodes()
    --Setup init node
    local initNode = NextNodes.InitNode
    if not initNode then initNode = FindNextInitNode(UsedNodes, true) end
    if not initNode then initNode = GetClosestValidNode() end
    --Add init node and all neighbors
    AddNextNode(initNode)
    for key, neighbor in pairs(initNode.neighbor) do
        AddNextNode(neighbor)
    end
    --Set next init node
    if #NextNodes == 0 then
        VipdLog(vERROR, "Unable to find valid next node.")
    else
        NextNodes.InitNode = FindNextInitNode(NextNodes, false)
    end
end

function GetNextNode()
    if #NextNodes == 0 then SetupNextNodes() end
    return table.remove(NextNodes, 1)
end
