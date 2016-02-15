function Teleport (idFrom, idTo)
    if idFrom == nil or idTo == nil then
        PrintTable (player.GetAll ())
    else
        local plyFrom = player.GetAll ()[idFrom]
        local plyTo = player.GetAll ()[idTo]
        VipdVlog (vINFO, "Teleporting " .. plyFrom:Name () .. " to where " .. plyTo:Name () .. " is looking.")

        local vStart = plyTo:GetShootPos ()
        local vForward = plyTo:GetAimVector ()
        local trace = { }
        trace.start = vStart
        trace.endpos = vStart + vForward * 2048
        trace.filter = plyTo
        tr = util.TraceLine (trace)
        Position = tr.HitPos
        Normal = tr.HitNormal
        Position = Position + Normal * 32
        plyFrom:SetPos (Position)
    end
end

local AINET_VERSION_NUMBER = 37
local SIZEOF_INT = 4
local SIZEOF_SHORT = 2

local function toUShort (b)
    local i = { string.byte (b, 1, SIZEOF_SHORT)}
    return i[1] + i[2] * 256
end

local function toInt (b)
    local i = { string.byte (b, 1, SIZEOF_INT)}
    i = i[1] + i[2] * 256 + i[3] * 65536 + i[4] * 16777216
    if(i > 2147483647) then return i - 4294967296 end
    return i
end

local function ReadInt (f) return toInt (f:Read (SIZEOF_INT)) end
local function ReadUShort (f) return toUShort (f:Read (SIZEOF_SHORT)) end

local function ParseFile (f)
    f = file.Open (f, "rb", "GAME")
    if(not f) then return end
    local ainet_ver = ReadInt (f)
    local map_ver = ReadInt (f)
    local nodegraph = {
        ainet_version = ainet_ver,
        map_version = map_ver
    }
    if(ainet_ver ~= AINET_VERSION_NUMBER) then
        MsgN ("Unknown graph file version: " .. ainet_ver)
        return
    end
    local numNodes = ReadInt (f)
    VipdLog (vINFO, "Found " .. numNodes .. " nodes!")
    local nodes = {}
    for i=1, numNodes do
        local v = Vector (f:ReadFloat (), f:ReadFloat (), f:ReadFloat ())
        local yaw = f:ReadFloat ()
        local flOffsets = {}
        for i=1, NUM_HULLS do
            flOffsets[i] = f:ReadFloat ()
        end
        local nodetype = f:ReadByte ()
        local nodeinfo = ReadUShort (f)
        local zone = f:ReadShort ()

        local node = {
            pos = v,
            yaw = yaw,
            offset = flOffsets,
            type = nodetype,
            info = nodeinfo,
            zone = zone,
            neighbor = {},
            numneighbors = 0,
            link = {},
            numlinks = 0
        }
        table.insert (nodes, node)
    end
    VipdLog (vINFO, "Finished reading in nodes")
    local numLinks = ReadInt (f)
    VipdLog (vINFO, "Found " .. numLinks .. " links!")
    local links = {}
    for i=1, numLinks do
        local link = {}
        local srcID = f:ReadShort ()
        local destID = f:ReadShort ()
        local nodesrc = nodes[srcID + 1]
        local nodedest = nodes[destID + 1]
        if(nodesrc and nodedest) then
            table.insert (nodesrc.neighbor, nodedest)
            nodesrc.numneighbors = nodesrc.numneighbors + 1

            table.insert (nodesrc.link, link)
            nodesrc.numlinks = nodesrc.numlinks + 1
            link.src = nodesrc
            link.srcID = srcID + 1

            table.insert (nodedest.neighbor, nodesrc)
            nodedest.numneighbors = nodedest.numneighbors + 1

            table.insert (nodedest.link, link)
            nodedest.numlinks = nodedest.numlinks + 1
            link.dest = nodedest
            link.destID = destID + 1
        else MsgN ("Unknown link source or destination " .. srcID .. " " .. destID) end
        local moves = {}
        for i=1, NUM_HULLS do
            moves[i] = f:ReadByte ()
        end
        link.move = moves
        table.insert (links, link)
    end
    VipdLog (vINFO, "Finished reading in links")
    local lookup = {}
    for i=1, numNodes do
        table.insert (lookup, ReadInt (f))
    end
    f:Close ()
    VipdLog (vINFO, "Finished reading ain file")
    nodegraph.nodes = nodes
    nodegraph.links = links
    return nodegraph
end

local function PosCanBeSeen(start, endpos)
    local trace = { }
    trace.start = start
    trace.endpos = endpos
    tr = util.TraceLine (trace)
    return not tr.Hit
end


local function NodeCanBeSeen (node)
    local Offset = Vector (0, 0, 10)
    local result = false
    for k, ply in pairs(player.GetAll()) do
        result = result or PosCanBeSeen(node.pos, ply:GetPos ())
        result = result or PosCanBeSeen (node.pos + Offset, ply:GetPos())
    end
    return result
end


function PrintNodeGraphs ()
    -- Only read in the node file once because it's an expensive operation
    if not nodegraph then
        f = "maps/graphs/" .. game.GetMap () .. ".ain"
        VipdLog (vDEBUG, "Reading: " .. f)
        nodegraph = ParseFile (f)
    end
    if not nodegraph then VipdLog (vINFO, "No nodegraph found for " .. game.GetMap ())
    else
        local nodes = nodegraph.nodes
        local ply = player.GetAll ()[1]
        VipdLog (vINFO, "Nodes: " .. #nodes)
        for k, node in pairs(nodes) do
            if NodeCanBeSeen (node) then
                VipdLog(vINFO, "Node is visible at: ".. tostring(node.pos))
                table.remove (nodes, k)
            end
        end
        VipdLog (vINFO, "Nodes that are not visible: " .. #nodes)
    end
end