--Utils shared by server and client
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
    return math.floor(GetPoints(ply) / GetLevelInterval())
end