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
    vDEBUG("Nodes: " .. #nodes)
    vipd.Nodes = nodes
    LogNodeCounts()
end
