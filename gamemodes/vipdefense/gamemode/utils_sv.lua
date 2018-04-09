-- Networking utils

util.AddNetworkString("gmod_notification")

local function SendNotification(ply, msg, level)
    net.Start("gmod_notification")
    net.WriteString(msg)
    net.WriteInt(level, 8)
    net.Send(ply)
end

function Notify(ply, msg)
    if IsValid(ply) then
        vTRACE("Notify to: " .. ply:Name() .. " - " .. msg)
        SendNotification(ply, msg, 1)
    else
        vINFO("Attempted to notify invalid player: " .. tostring(ply))
    end
end

function BroadcastError(msg)
    vDEBUG("Broadcast error: " .. msg)
    for k, ply in pairs(player.GetAll()) do
        SendNotification(ply, msg, 2)
    end
end

function BroadcastNotify(msg)
    vDEBUG("Broadcast notify: " .. msg)
    for k, ply in pairs(player.GetAll()) do
        SendNotification(ply, msg, 1)
    end
end

-- Messaging utils

function MsgPlayer(ply, msg)
    if IsValid(ply) then
        vDEBUG("Message: " .. ply:Name() .. msg)
        ply:PrintMessage(HUD_PRINTTALK, msg)
    else
        vERROR("Attempted to message invalid player: " .. tostring(ply))
    end
end

function MsgCenter(msg)
    vDEBUG("Center Message: " .. msg)
    PrintMessage(HUD_PRINTCENTER, msg)
end

-- Other

function IsBitSet(val, hasBit)
    return bit.band(val, hasBit) == hasBit
end

function VipdGetPlayer(idName)
    local ply
    if tonumber(idName) ~= nil then
        idName = tonumber(idName)
        ply = player.GetAll()[idName]
    end
    if ply == nil then
        for k, p in pairs(player.GetAll()) do
            if p:Name() == idName then
                ply = p
            end
        end
    end
    return ply
end

function GetClosestPlayer(pos, maxDistance, minDistance)
    local closestPlayer
    for k, ply in pairs(player.GetAll()) do
        local distance = pos:Distance(ply:GetPos())
        if distance < maxDistance and distance > minDistance then
            maxDistance = distance
            closestPlayer = ply
        end
    end
    return closestPlayer
end

--======================--
--Level System Utilities--
--======================--
function ResetLevelSystem()
    for k, ply in pairs(player.GetAll()) do
        ResetVply(ply:Name())
        ply:SetHealth(100)
        ply:SetArmor(0)
        VipdLoadout(ply, true)
        AddPoints(ply, INITIAL_POINTS)
    end
end
function GetLevelInterval()
    return GetConVarNumber("vipd_pointsperlevel")
end

function GetGradeInterval()
    return GetConVarNumber("vipd_levelspergrade")
end

function GetActualPoints(ply)
    return GetVply(ply:Name()).points
end

function GetAvailablePoints(ply)
    local vply = GetVply(ply:Name())
    return GetPoints(ply) - vply.used
end

function GetPoints(ply)
    local vply = GetVply(ply:Name())
    local points = GetActualPoints(ply)
    return math.floor(points * vply.handicap)
end

function SetPoints(ply, points)
    GetVply(ply:Name()).points = points
end

function UsePoints(ply, points)
    local vply = GetVply(ply:Name())
    vply.used = vply.used + points
end

function GetGrade(ply)
    return GetGradeForLevel(GetLevel(ply))
end

function GetGradeForLevel(level)
    local grade = math.floor(level / GetGradeInterval())
    if grade < 1 then
        grade = 0
    end
    return grade
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
        pointsToNextLevel = LevelTable[plyLevel] - plyPoints
    end
    return pointsToNextLevel
end

function LevelsToNextGrade(ply)
    return GetGradeInterval() - GetLevel(ply) % GetGradeInterval()
end

function ResetVply(name)
    local vply = GetVply(name)
    vply.points = 0
    vply.used = 0
    vply.weapons = { }
end

local function InitVply(name)
    -- TODO: The key should be the name, for faster indexing and searching
    table.insert(vipd.Players, { name = name, points = 0, handicap = 1, used = 0, weapons = { }, stats = GetDefaultStats() })
end

function GetVplyByPlayer(ply)
    if IsValid(ply) and ply:IsPlayer() then
        return GetVply(ply:Name())
    end
end

function GetVply(name)
    local found_vply
    -- TODO: The key should be the name, for faster indexing and searching
    for key, vply in pairs(vipd.Players) do
        if vply.name == name then
            found_vply = vply
        end
    end
    if not found_vply then
        InitVply(name)
        return GetVply(name)
    end
    return found_vply
end

function varTypeCheck(var, expType, varName)
    if type(var) ~= expType then
        vINFO("Variable [" .. varName .. "] was incorrect type, expected [" .. expType .. "], actual [" .. type(var) .. "], value [" .. tostring(var) .. "]")
    end
    return type(var) == expType
end

function IsAdmin(ply)
    return IsValid(ply) and ply:IsAdmin()
end

function GetWeaponByNameOrClass(name)
    for key, vipd_weapon in pairs(vipd_weapons) do
        if vipd_weapon.name == name then
            return vipd_weapon
        end
        if vipd_weapon.class == name then
            return vipd_weapon
        end
    end
end
