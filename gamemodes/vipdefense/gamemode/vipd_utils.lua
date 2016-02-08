function GetPoints(ply)
    return ply:Frags()
end

function GetGrade(ply)
    return math.floor(GetLevel(ply) / GetGradeInterval())
end

function GetLevel(ply)
    return math.floor(GetPoints(ply) / GetLevelInterval())
end

function PointsToNextLevel(ply)
    local pointsNeeded = GetLevelInterval() - GetPoints(ply) % GetLevelInterval()
    if GetPoints(ply) < 1 then pointsNeeded = GetLevelInterval() - GetPoints(ply) end
    return pointsNeeded
end

function LevelsToNextGrade(ply)
    return GetGradeInterval() - GetLevel(ply) % GetGradeInterval()
end

function MsgPlayer(ply, msg)
    ply:PrintMessage(HUD_PRINTTALK, msg)
end

function GetLevelInterval()
    return GetConVarNumber("vipd_pointsperlevel")
end

function GetGradeInterval()
    return GetConVarNumber("vipd_levelspergrade")
end

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

util.AddNetworkString("gmod_notification")

function Error(ply, msg)
    SendNotification(ply, msg, 2)
end

function Notify(ply, msg)
    SendNotification(ply, msg, 1)
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