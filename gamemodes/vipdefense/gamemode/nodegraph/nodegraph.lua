--Most of the code in this file is adapted from the addon Nodegraph Editor

local AINET_VERSION_NUMBER = 37
local SIZEOF_INT = 4
local SIZEOF_SHORT = 2
vipd_nodegraph = nil

local function toUShort(b)
    local i = { string.byte(b, 1, SIZEOF_SHORT)}
    return i[1] + i[2] * 256
end

local function toInt(b)
    local i = { string.byte(b, 1, SIZEOF_INT)}
    i = i[1] + i[2] * 256 + i[3] * 65536 + i[4] * 16777216
    if(i > 2147483647) then return i - 4294967296 end
    return i
end

local function ReadInt(f) return toInt(f:Read(SIZEOF_INT)) end
local function ReadUShort(f) return toUShort(f:Read(SIZEOF_SHORT)) end

local function ParseFile(f)
    f = file.Open(f, "rb", "GAME")
    if(not f) then
        vDEBUG("No AIN file found")
        return
    end
    local ainet_ver = ReadInt(f)
    local map_ver = ReadInt(f)
    local vipd_nodegraph = {
        ainet_version = ainet_ver,
        map_version = map_ver
    }
    if(ainet_ver ~= AINET_VERSION_NUMBER) then
        MsgN("Unknown graph file version: " .. ainet_ver)
        return
    end
    local numNodes = ReadInt(f)
    vDEBUG("Found " .. numNodes .. " nodes!")
    local nodes = {}
    for i=1, numNodes do
        local v = Vector(f:ReadFloat(), f:ReadFloat(), f:ReadFloat())
        local yaw = f:ReadFloat()
        local flOffsets = {}
        for i=1, NUM_HULLS do
            flOffsets[i] = f:ReadFloat()
        end
        local nodetype = f:ReadByte()
        local nodeinfo = ReadUShort(f)
        local zone = f:ReadShort()

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
        table.insert(nodes, node)
    end
    vDEBUG("Finished reading in nodes")
    local numLinks = ReadInt(f)
    vDEBUG("Found " .. numLinks .. " links!")
    local links = {}
    for i=1, numLinks do
        local link = {}
        local srcID = f:ReadShort()
        local destID = f:ReadShort()
        local nodesrc = nodes[srcID + 1]
        local nodedest = nodes[destID + 1]
        if(nodesrc and nodedest) then
            table.insert(nodesrc.neighbor, nodedest)
            nodesrc.numneighbors = nodesrc.numneighbors + 1

            table.insert(nodesrc.link, link)
            nodesrc.numlinks = nodesrc.numlinks + 1
            link.src = nodesrc
            link.srcID = srcID + 1

            table.insert(nodedest.neighbor, nodesrc)
            nodedest.numneighbors = nodedest.numneighbors + 1

            table.insert(nodedest.link, link)
            nodedest.numlinks = nodedest.numlinks + 1
            link.dest = nodedest
            link.destID = destID + 1
        else MsgN("Unknown link source or destination " .. srcID .. " " .. destID) end
        local moves = {}
        for i=1, NUM_HULLS do
            moves[i] = f:ReadByte()
        end
        link.move = moves
        table.insert(links, link)
    end
    vDEBUG("Finished reading in links")
    local lookup = {}
    for i=1, numNodes do
        table.insert(lookup, ReadInt(f))
    end
    f:Close()
    vDEBUG("Finished reading ain file")
    vipd_nodegraph.nodes = nodes
    vipd_nodegraph.links = links
    return vipd_nodegraph
end

function GetVipdNodegraph()
    --TODO: Only read in the node file once because it's an expensive operation
    if not vipd_nodegraph then
        f = "maps/graphs/" .. game.GetMap() .. ".ain"
        vDEBUG("Reading: " .. f)
        vipd_nodegraph = ParseFile(f)
        if not vipd_nodegraph then vINFO("No vipd_nodegraph found for " .. game.GetMap()) end
    else
        vINFO("Nodegraph already loaded from file.")
    end
    return vipd_nodegraph
end
