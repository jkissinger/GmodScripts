-- Level system utils
function GetWeightedRandomTier()
    chance = math.random(1, 15)
    if chance <= 8 then
        return 1
    elseif chance <= 12 then
        return 2
    elseif chance <= 14 then
        return 3
    elseif chance == 15 then
        return 4
    end
end

-- Wave system utils
function GetWaveTier()
    local totalGradeValue = 0
    local numPlayers = 0
    for k, ply in pairs(player.GetAll()) do
        totalGradeValue = totalGradeValue + GetGrade(ply)
        numPlayers = numPlayers + 1
    end
    local waveTier = math.floor(totalGradeValue / numPlayers) + 1
    if waveTier < 1 then waveTier = 1 end
    return waveTier
end

function GetTotalWaveNPCValue()
    local total = 0
    for k, v in pairs(player.GetAll()) do
        total = total + GetWaveTier() * GetGradeInterval() * GetLevelInterval()
    end
    return total
end

function GetMaxNPCValueForWave()
    return GetWaveTier() * 3 + 4
end

-- Networking utils

util.AddNetworkString("gmod_notification")

function Error(ply, msg)
    SendNotification(ply, msg, 2)
end

function Notify(ply, msg)
    SendNotification(ply, msg, 1)
end

function BroadcastError(msg)
    for k, ply in pairs(player.GetAll()) do
        Error(ply, msg)
    end
end

function BroadcastNotify(msg)
	for k, ply in pairs(player.GetAll()) do
        Notify(ply, msg)
    end
end

function SendNotification(ply, msg, level)
    net.Start("gmod_notification")
    net.WriteString(msg)
    net.WriteInt(level, 8)
    net.Send(ply)
end

util.AddNetworkString("wave_update")

function WaveUpdateClient(netTable)
    net.Start("wave_update")
    net.WriteTable(netTable)
    net.Broadcast()
end

-- Messaging utils

function MsgPlayer(ply, msg)
    ply:PrintMessage(HUD_PRINTTALK, msg)
end

function MsgCenter(msg)
    PrintMessage(HUD_PRINTCENTER, msg)
end

-- Other

function GenerateNavmesh ()
    if not navmesh.IsLoaded () then
        VipdLog (vINFO, "Generating new navmesh...")
        navmesh.BeginGeneration ()
    else
        BroadcastNotify("This map already has a navmesh loaded!")
    end
end