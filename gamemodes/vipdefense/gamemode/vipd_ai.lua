local function PosCanBeSeen(start, endpos)
    local trace = { }
    trace.start = start
    trace.endpos = endpos
    tr = util.TraceLine (trace)
    return not tr.Hit
end

local function PosValidDistance(ply, pos)
    local distance = pos:Distance(ply:GetPos())
    return distance < minSpawnDistance or distance > maxSpawnDistance
end

function IsNodeValid (node)
    local Offset = Vector (0, 0, 10)
    local result = false
    for k, ply in pairs(player.GetAll()) do
        --test node visibility, we don't want to spawn where players can see it
        result = result or PosCanBeSeen (node.pos, ply:GetPos ())
        result = result or PosCanBeSeen (node.pos + Offset, ply:GetPos())
        --test spawn distance
        result = result or PosValidDistance(ply, node.pos)
    end
    return result
end

function GetNodes ()
    nodegraph = GetNodeGraph()
    local nodes = nodegraph.nodes
    VipdLog (vINFO, "Nodes: " .. #nodes)
    for k, node in pairs(nodes) do
        vipd.nodes[k] = node
    end
    VipdLog (vINFO, "Nodes that are valid: " .. #vipd.nodes)
end



--Thinking

function VipdThink()
    netTable = {
        ["waveTotal"] = #WaveEnemyTable,
        ["VipHealth"] = VipHealth,
        ["VipName"] = VipName,
        ["WaveIsInProgress"] = WaveIsInProgress,
        ["CurrentWave"] = CurrentWave
    }
    WaveUpdateClient(netTable)
    if WaveIsInProgress then
        if VipHealth <= 0 then
            FailedWave()
        elseif #WaveEnemyTable == 0 then
            CompletedWave()
        end
    end
end

hook.Add("Think", "Make Wave NPCs Think", VipdThink)