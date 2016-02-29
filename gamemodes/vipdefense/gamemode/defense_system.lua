local function ResetMap()
    InitSystemGlobals()
    NextNodes = { }
    UsedNodes = { }
    game.CleanUpMap(false, {} )
    for k, ply in pairs(player.GetAll()) do
        ply:StripWeapons()
        ply:Give("weapon_crowbar")
        ply:Give("weapon_physcannon")
        SetPoints(ply, 0)
        ply:SetHealth(100)
        ply:SetArmor(0)
    end
end

function InitDefenseSystem()
    if DefenseSystem then return end
    MsgCenter("Initializing invasion.")
    ResetMap()
    GetNodes()
    if #vipd.Nodes < 50 then
        DefenseSystem = false
        BroadcastError("Can't init invasion because "..game.GetMap().." has less than 50 AI nodes!")
    else
        DefenseSystem = true
        CheckNpcs()
    end
end

function StopDefenseSystem()
    MsgCenter("Shutting down invasion.")
    DefenseSystem = false
    ResetMap()
end

--=================--
--Utility Functions--
--=================--

local function GetAverageTier()
    local gradeSum = 0
    for k, ply in pairs(player.GetAll()) do
        gradeSum = gradeSum + GetGrade(ply)
    end
    local avgTier = math.floor(gradeSum / #player.GetAll()) + 1
    if avgTier < 1 then avgTier = 1 end
    return avgTier
end

function GetMaxEnemyValue()
    return GetAverageTier() * 5
end

function GetFriendlies()
    local friendlies = { }
    for key, ent in pairs(ents.GetAll()) do
        if ent.isFriendly then table.insert(friendlies, ent) end
    end
    return friendlies
end

function GetEnemies()
    local enemies = { }
    for key, ent in pairs(ents.GetAll()) do
        if ent.isEnemy then table.insert(enemies, ent) end
    end
    return enemies
end

function GetVipdNpcs()
    local npcs = { }
    for key, ent in pairs(ents.GetAll()) do
        if ent.isEnemy or ent.isFriendly then table.insert(npcs, ent) end
    end
    return npcs
end

--=================--
--Rescuing Friendly--
--=================--

local function Rescue(ply, ent)
    timer.Simple (1, function () if (IsValid (ent) ) then ent:Remove () end end )
    local healthId = math.random(5)
    FriendlySay(ent, "health0"..healthId)

    -- Make it non solid
    ent:SetNotSolid (true)
    ent:SetMoveType (MOVETYPE_NONE)
    ent:SetNoDraw (true)

    -- Send Effect
    local ed = EffectData ()
    ed:SetEntity (ent)
    util.Effect ("entity_remove", ed, true, true)
    Notify (ply, "You rescued a ".. VipdFriendlyTeam .."!")
    AddPoints(ply, FriendlyPointValue)
    GiveBonuses(ply, 1)
    currentNpcs = currentNpcs - 1
    RescuedFriendlys = RescuedFriendlys + 1
    CheckNpcs()
end

function GM:FindUseEntity (ply, ent)
    if ent.isFriendly then
        Rescue(ply, ent)
    else
        return ent
    end
end
