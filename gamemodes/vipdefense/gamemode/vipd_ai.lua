function VipdThink()
    for k, npc in pairs(WaveEnemyTable) do
        if npc:IsValid() and npc:Health() > 0 then
            SetBehavior(npc)
        else
            table.remove(WaveEnemyTable, k)
        end
    end
    local VipHealth = 0
    if IsValid(VIP) then VipHealth = VIP:Health() end
    netTable = {
        ["waveTotal"] = #WaveEnemyTable,
        ["VipHealth"] = VipHealth,
        ["VipName"] = VipName,
        ["WaveIsInProgress"] = WaveIsInProgress,
        ["CurrentWave"] = CurrentWave
    }
    WaveUpdateClient(netTable)
    if WaveIsInProgress then
        if VipHealth <= 0 then
            FailedWave()
        elseif #WaveEnemyTable == 0 then
            CompletedWave()
        end
    end
end

function SetBehavior(NPC)
    if not WaveIsInProgress then return end
    local vipPos = VIP:GetPos()
    local npcPos = NPC:GetPos()
    local dist = math.Dist(vipPos.x, vipPos.y, npcPos.x, npcPos.y)
    if not NPC.Counter then NPC.Counter = 0 end
    if not NPC.Stuck then NPC.Stuck = 0 end
    if IsValid(NPC:GetEnemy()) then
        if NPC.Counter > 500 then VipdLog(vDEBUG, NPC:GetClass().." is fighting a " .. NPC:GetEnemy():GetClass().." at "..tostring(npcPos)) end
        VipdLog(vTRACE, "NPC is fighting a " .. NPC:GetEnemy():GetClass())
        NPC.Stuck = NPC.Stuck - 1
    elseif not NPC:IsMoving() and NPC:IsCurrentSchedule(SCHED_FORCED_GO_RUN) then
		HandleStuckNPC(NPC)
    elseif NPC:IsMoving() and NPC:IsCurrentSchedule(SCHED_FORCED_GO_RUN) and dist < minPatrolDist then
        if NPC.Counter > 500 then VipdLog(vDEBUG, NPC:GetClass().." targeting vip "..tostring(npcPos)) end
        VipdLog(vTRACE, "Too close to VIP, targeting them")
        --NPC:SetSchedule(SCHED_PATROL_WALK)
        NPC:ClearSchedule()		
        NPC:SetEnemy(VIP)
        --NPC:SetSchedule(SCHED_CHASE_ENEMY)
        NPC.Stuck = NPC.Stuck - 1
    elseif not NPC:IsMoving() and dist < maxPatrolDist then
        if NPC.Counter > 500 then VipdLog(vDEBUG, NPC:GetClass().." patrolling "..tostring(npcPos)) end
        VipdLog(vTRACE, "Not moving while in patrol range, patrolling")
        --NPC:SetSchedule(SCHED_PATROL_WALK)
        NPC:ClearSchedule()		
        NPC:SetEnemy(VIP)
        NPC.Stuck = NPC.Stuck - 1
    elseif not NPC:IsMoving() then
        if NPC.Counter > 500 then VipdLog(vDEBUG, NPC:GetClass().." running to VIP "..tostring(npcPos)) end
        VipdLog(vTRACE, "Running to VIP")
        local vipPos = VIP:GetPos()
        NPC:SetLastPosition(vipPos)
        NPC:SetSchedule(SCHED_FORCED_GO_RUN)
        NPC.Stuck = NPC.Stuck - 1
    end
    NPC.Counter = NPC.Counter + 1
    if NPC.Counter > 501 or NPC.Counter < 0 then NPC.Counter = 0 end
end

function HandleStuckNPC(NPC)
        -- Can't remove yet, because they don't have a chance to move after being told to before this is called the first time
        -- NPC:Remove()
	if NPC.Stuck then
		if NPC.Stuck > 250 then
			VipdLog(vWARN, "Killing " .. NPC:GetClass().." because it's stuck.")
			NPC:TakeDamage(999, game.GetWorld(), game.GetWorld())
			NPC.Stuck = 0
		else
			NPC.Stuck = NPC.Stuck + 1
		end
	else
		NPC.Stuck = 0
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

hook.Add("Think", "Make Wave NPCs Think", VipdThink)