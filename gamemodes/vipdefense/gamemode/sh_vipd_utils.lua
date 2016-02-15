
-- Utils shared by server and client

function GetLevelInterval()
    return GetConVarNumber("vipd_pointsperlevel")
end

function GetGradeInterval()
    return GetConVarNumber("vipd_levelspergrade")
end

function GetPoints(ply)
    return ply:Frags()
end

function GetGrade(ply)
    return math.floor(GetLevel(ply) / GetGradeInterval())
end

function GetLevel(ply)
    local plyPoints = GetPoints(ply)
    local plyLevel = 1
    if LevelTable then
        for level, levelPoints in pairs(LevelTable) do
            if plyPoints > levelPoints then
                plyLevel = level + 1
            else
                break
            end
        end
    end
    return plyLevel
end

function PointsToNextLevel(ply)
    local plyPoints = GetPoints(ply)
    local plyLevel = GetLevel(ply)
    local pointsToNextLevel = 0
    if LevelTable and plyLevel <= #LevelTable then
        pointsToNextLevel = LevelTable[plyLevel + 1] - plyPoints
    end
    return pointsToNextLevel
end

function LevelsToNextGrade(ply)
    return GetGradeInterval() - GetLevel(ply) % GetGradeInterval()
end

--TODO: add hook to trigger this when the convar pointsperlevel changes
LevelTable = { }
for i = 1, MaxLevel, 1 do
    local base = GetLevelInterval() * i
    local modifier = GetLevelInterval() * 0.2
    local levelBase = i * i * modifier
    local points = math.floor(base + levelBase)
    table.insert(LevelTable, points)
end