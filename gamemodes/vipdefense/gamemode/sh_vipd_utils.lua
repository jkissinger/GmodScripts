
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

LevelTable = { }
for i = 1, 20, 1 do
    local base = GetLevelInterval() * i
    local modifier = GetLevelInterval() * .2
    local levelBase = i * i * modifier
    print("Base: "..base.." LevelBase: "..levelBase)
    local points = math.floor(base + levelBase)
    table.insert(LevelTable, points)
end