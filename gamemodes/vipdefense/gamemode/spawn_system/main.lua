local function IsVipdNpc(ent)
return ent ~= nil and ent.team ~= nil and ent.team.name ~= nil
end

function IsEnemy(ent)
    return IsVipdNpc(ent) and not IsAlly(ent)
end

function IsAlly(ent)
    return IsVipdNpc(ent) and (ent.team.name == VipdAllyTeam.name or ent.team.name == VipdVipTeam.name)
end

local function DefenseSystemKillConfirm(victim, ply, inflictor)
    if DefenseSystem then
        if IsEnemy(victim) then DeadEnemies = DeadEnemies + 1 end
        if IsAlly(victim) then
            DeadAllies = DeadAllies + 1
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

function CalculateMaxEnemyValue()
    local total_points = 0
    for key, vply in pairs(vipd.Players) do
        total_points = total_points + vply.points
    end
    local average_points = total_points / #vipd.Players
    local calculated_max = math.floor(average_points / MAX_ENEMY_DIVISOR)
    calculated_max = calculated_max + MIN_NPC_VALUE
    return calculated_max
end

--=================--
--Rescuing Ally--
--=================--

local function Rescue(ply, ent)
    if ent.lastAttacker then ent.lastAttacker = nil end
    timer.Simple(1, function() if(IsValid(ent) ) then ent:Remove() end end )
    local healthId = math.random(5)
    AllySay(ent, SOUND_TYPE_RESCUE)

    -- Make it non solid
    ent:SetNotSolid(true)
    ent:SetMoveType(MOVETYPE_NONE)
    ent:SetNoDraw(true)

    -- Send Effect
    local ed = EffectData()
    ed:SetEntity(ent)
    util.Effect("entity_remove", ed, true, true)
    local npc_data = GetNpcData(ent)
    Notify(ply, "You rescued " .. npc_data.name .. "!")
    AddPoints(ply, ent.team.points)
    GiveBonuses(ply, 1)
    RescuedAllies = RescuedAllies + 1
end

function GM:FindUseEntity(ply, ent)
    if ent ~= nil and IsValid(ent) then
    --vDEBUG(ent:GetKeyValues())
    end
    if ent ~= nil and IsAlly(ent) then
        Rescue(ply, ent)
    else
        return ent
    end
end

function CheckSpawnSystemFinished()
    if DefenseSystem and RemainingNodeCount() == 0 and not TAGGED_ENEMY then
        MsgCenter("CONGRATULATIONS YOU WIN!")
        StopDefenseSystem()
    end 
end



hook.Add( "OnNPCKilled", "VipdDefenseNPCKilled", DefenseSystemKillConfirm)
