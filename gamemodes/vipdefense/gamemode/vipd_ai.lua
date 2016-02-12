hook.Add("Think", "Make Wave NPCs Think", onThink)

function setBehavior(NPC)
    if not WaveIsInProgress then return end
    local vipPos = VIP:GetPos()
    local npcPos = NPC:GetPos()
    local dist = math.Dist(vipPos.x, vipPos.y, npcPos.x, npcPos.y)
    if IsValid(NPC:GetEnemy()) then
        --print("NPC is fighting a " .. NPC:GetEnemy():GetClass())
    elseif not NPC:IsMoving() and NPC:IsCurrentSchedule(SCHED_FORCED_GO_RUN) then
        if CurrentWaveValue <= 20 then
            print("I can't reach the VIP, I'm at:" .. tostring(NPC:GetPos()))
        end
        -- Can't remove yet, because they don't have a chance to move after being told to before this is called the first time
        -- NPC:Remove()
    elseif NPC:IsMoving() and NPC:IsCurrentSchedule(SCHED_FORCED_GO_RUN) and dist < minPatrolDist then
        --print("Too close to VIP, targeting them")
        NPC:SetSchedule(SCHED_PATROL_WALK)
        NPC:SetEnemy(VIP)
    elseif not NPC:IsMoving() and dist < maxPatrolDist then
        --print("Not moving while in patrol range, patrolling")
        NPC:SetSchedule(SCHED_PATROL_WALK)
    elseif not NPC:IsMoving() then
        --print("Running to VIP")
        local vipPos = VIP:GetPos()
        NPC:SetLastPosition(vipPos)
        NPC:SetSchedule(SCHED_FORCED_GO_RUN)
    end
end

function wanderRandomly(NPC)
    local x = math.random(-50, 50)
    local y = math.random(-50, 50)
    NPC:NavSetWanderGoal(100, 100)
    NPC:SetSchedule(SCHED_IDLE_WANDER)
end

function experiment(NPC)
    local x = math.random(-50, 50)
    local y = math.random(-50, 50)
    -- NPC:NavSetWanderGoal(100, 100)
    local destPos = NPC:GetPos() + Vector(x, y, 0)
    local vipPos = VIP:GetPos()
    NPC:NavSetGoal(vipPos)
    NPC:SetLastPosition(vipPos)
    NPC:SetSchedule(SCHED_FORCED_GO_RUN)
    -- NPC:SetSchedule(SCHED_PATROL_RUN)
end