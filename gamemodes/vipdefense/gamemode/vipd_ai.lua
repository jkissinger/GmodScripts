hook.Add("Think", "Make Wave NPCs Think", onThink)

function setBehavior(npc)
    if not waveIsInProgress then return end
    local vipPos = VIP:GetPos()
    local npcPos = npc:GetPos()
    local dist = math.Dist(vipPos.x, vipPos.y, npcPos.x, npcPos.y)
    if IsValid(npc:GetEnemy()) then
        print("NPC is fighting a " .. npc:GetEnemy():GetClass())
    elseif not npc:IsMoving() and npc:IsCurrentSchedule(SCHED_FORCED_GO_RUN) then
        print("I can't reach the VIP, I'm at:" .. tostring(npc:GetPos()))
        -- Can't remove yet, because they don't have a chance to move after being told to before this is called the first time
        -- npc:Remove()
    elseif npc:IsMoving() and npc:IsCurrentSchedule(SCHED_FORCED_GO_RUN) and dist < minPatrolDist then
        print("Too close to VIP, targeting them")
        npc:SetSchedule(SCHED_PATROL_WALK)
        npc:SetEnemy(VIP)
    elseif not npc:IsMoving() and dist < maxPatrolDist then
        print("Not moving while in patrol range, patrolling")
        npc:SetSchedule(SCHED_PATROL_WALK)
    elseif not npc:IsMoving() then
        print("Running to VIP")
        local vipPos = VIP:GetPos()
        npc:SetLastPosition(vipPos)
        npc:SetSchedule(SCHED_FORCED_GO_RUN)
    end
end

function wanderRandomly(npc)
    local x = math.random(-50, 50)
    local y = math.random(-50, 50)
    npc:NavSetWanderGoal(100, 100)
    npc:SetSchedule(SCHED_IDLE_WANDER)
end

function experiment(npc)
    local x = math.random(-50, 50)
    local y = math.random(-50, 50)
    -- npc:NavSetWanderGoal(100, 100)
    local destPos = npc:GetPos() + Vector(x, y, 0)
    local vipPos = VIP:GetPos()
    npc:NavSetGoal(vipPos)
    npc:SetLastPosition(vipPos)
    npc:SetSchedule(SCHED_FORCED_GO_RUN)
    -- npc:SetSchedule(SCHED_PATROL_RUN)
end