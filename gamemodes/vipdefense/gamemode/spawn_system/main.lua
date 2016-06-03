function IsEnemy(ent)
    return ent ~= nil and ent.team ~= nil and ent.team.name ~= nil and not IsFriendly(ent)
end

function IsFriendly(ent)
    return ent ~= nil and ent.team ~= nil and ent.team.name ~= nil and (ent.team.name == VipdFriendlyTeam.name or ent.team.name == VipdVipTeam.name)
end

local function DefenseSystemKillConfirm(victim, ply, inflictor)
    if DefenseSystem then
        if IsEnemy(victim) then DeadEnemies = DeadEnemies + 1 end
        if IsFriendly(victim) then
            if IsValid(ply) and ply:IsPlayer() then
                BroadcastNotify(ply:Name().." killed a "..victim.team.name.."!")
                AddPoints(ply, -50)
            end
            DeadFriendlys = DeadFriendlys + 1
        end
        if TotalEnemies - DeadEnemies == 0 and CurrentNpcs == 0 then
            MsgCenter("You have successfully held off the invasion on "..game.GetMap().."!")
            DefenseSystem = false
        end
        if CurrentNpcs == 0 then
            MsgCenter("I think you successfully held off the invasion!")
        end
    end
end

--=================--
--Utility Functions--
--=================--

local function GetAverageTier()
    local gradeSum = 0
    for k, ply in pairs(player.GetAll()) do
        gradeSum = gradeSum + GetGrade(ply)
    end
    local avgTier = math.floor(gradeSum / #player.GetAll())
    return avgTier
end

function GetMaxEnemyValue()
    return GetAverageTier() * 5 + 3
end

function GetVipdNpcs()
    local npcs = { }
    for key, ent in pairs(ents.GetAll()) do
        if ent.team then table.insert(npcs, ent) end
    end
    return npcs
end

--=================--
--Rescuing Friendly--
--=================--

local function Rescue(ply, ent)
    if ent.lastAttacker then ent.lastAttacker = nil end
    timer.Simple(1, function() if(IsValid(ent) ) then ent:Remove() end end )
    local healthId = math.random(5)
    FriendlySay(ent, "health0"..healthId)

    -- Make it non solid
    ent:SetNotSolid(true)
    ent:SetMoveType(MOVETYPE_NONE)
    ent:SetNoDraw(true)

    -- Send Effect
    local ed = EffectData()
    ed:SetEntity(ent)
    util.Effect("entity_remove", ed, true, true)
    local classname = ent:GetClass()
    local name = GetNameFromClass(classname)
    Notify(ply, "You rescued " .. name .. "!")
    AddPoints(ply, ent.team.points)
    GiveBonuses(ply, 1)
    RescuedFriendlys = RescuedFriendlys + 1
end

function GM:FindUseEntity(ply, ent)
    if ent ~= nil and IsValid(ent) then
        --vDEBUG(ent:GetKeyValues())
    end
    if ent ~= nil and IsFriendly(ent) then
        Rescue(ply, ent)
    else
        return ent
    end
end



hook.Add( "OnNPCKilled", "VipdDefenseNPCKilled", DefenseSystemKillConfirm)
