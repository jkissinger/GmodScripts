local function PosVisible(start, endpos, player)
    local trace = { }
    trace.start = start
    trace.endpos = endpos
    trace.filter = player
    tr = util.TraceLine (trace)
    --if tr.Hit then VipdLog(vINFO, "Trace hit material: ") end
    return (not tr.Hit)
end

local function PosValidDistance(ply, pos)
    local distance = pos:Distance(ply:GetPos())
    return distance > minSpawnDistance and distance < maxSpawnDistance
end

function IsNodeValid (node)
    local Offset = Vector (0, 0, 10)
    local result = true
    for k, ply in pairs(player.GetAll()) do
        --test node visibility, we don't want to spawn where players can see it
        result = result and not PosVisible (node.pos, ply:EyePos(), ply)
        result = result and not PosVisible (node.pos + Offset, ply:EyePos(), ply)
        --test spawn distance
        result = result and PosValidDistance(ply, node.pos)
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
        ["EnemiesLeft"] = #vipd.nodes,
        ["VipHealth"] = VipHealth,
        ["VipName"] = VipName,
        ["ActiveSystem"] = AdventureSystem,
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