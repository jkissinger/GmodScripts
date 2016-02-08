function Debug()
    if not navmesh.IsLoaded() then
        print("Generating new navmesh...")
        navmesh.BeginGeneration()
        return
    end
    local ply = player.GetAll()[1]
    SpawnVIP(ply:GetPos())
    local counter = 0
    for l, w in pairs(navmesh.GetAllNavAreas()) do
        local distance = w:GetCenter():Distance(VIP:GetPos())
        if distance > minSpawnDist and distance < maxSpawnDist then
            if counter < 20 then
                SpawnEnemyNPC("npc_zombie", w:GetCenter())
                counter = counter + 1
            end
        end
    end
end

function SpawnVIP(startPos)
    -- VIP = ents.Create("doll01")
    VIP = ents.Create("npc_citizen")
    VIP:SetPos(startPos + Vector(0, 30, 20))
    VIP:Spawn()
    VIP:UseAssaultBehavior()
end

function SpawnEnemyNPC(className, startPos)
    local ent = ents.Create(className)
    ent:SetPos(startPos + Vector(0, 0, 20))
    ent:Spawn()
    table.insert(waveNpcTable, ent)
    -- if bit.band(ent:CapabilitiesGet(), CAP_MOVE_GROUND) then print(className .. " can move ground!") end
end

function onThink()
    local waveTotal = 0
    for k, npc in pairs(waveNpcTable) do
        if npc:IsValid() and npc:Health() > 0 then
            setBehavior(npc)
            waveTotal = waveTotal + 1
        else
            table.remove(waveNpcTable, k)
        end
    end
    local vipHealth = 0
    if IsValid(VIP) then vipHealth = VIP:Health() end
    netTable = { ["waveTotal"] = waveTotal, ["vipHealth"] = vipHealth }
    WaveUpdateClient(netTable)
end

hook.Add("Think", "Make Wave NPCs Think", onThink)

function setBehavior(npc)
    print("Checking distance")
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
        npc:ClearSchedule()
        npc:SetEnemy(VIP)
    elseif not npc:IsMoving() and dist < maxPatrolDist then
        print("Not moving while in patrol range, patrolling")
        npc:ClearSchedule()
        npc:SetSchedule(SCHED_PATROL_WALK)
    elseif not npc:IsMoving() then
        print("Running to VIP")
        local vipPos = VIP:GetPos()
        npc:ClearSchedule()
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