function SetBehavior(npc)
    if IsFriendly(npc) then
        local ply = GetClosestPlayer(npc:GetPos(), MIN_SPAWN_DISTANCE - 100, 0)
        if ply then
            npc:SetLastPosition(ply:GetPos() )
            npc:SetSchedule(SCHED_FORCED_GO_RUN)
        end
    else
        local class = npc:GetClass()
        if npc:GetEnemy() then
            if npc:IsCurrentSchedule(SCHED_FORCED_GO_RUN) then
                npc:ClearSchedule()
                vTRACE(class.." was running, but has an enemy so stop running.")
            end
        elseif class == "npc_stalker" and npc:HasCondition(7) then
            -- Need to make stalker's fight by default somehow?
            npc:SetNPCState(NPC_STATE_COMBAT)
            npc:SetSchedule(SCHED_RANGE_ATTACK1)
            vDEBUG("Attempted to make stalker attack something")
        elseif class == "npc_strider" and npc:HasCondition(61) then
            npc:DropToFloor()
            vDEBUG("Dropped flying strider")
        elseif npc:GetNPCState() < NPC_STATE_ALERT then npc:SetNPCState(NPC_STATE_ALERT)
        elseif npc:IsCurrentSchedule(SCHED_FORCED_GO_RUN) and (npc:HasCondition(32) or GetClosestPlayer(npc:GetPos(), MIN_SPAWN_DISTANCE, 0)) then
            -- npc is running, but they can see a player or are too close, stop running
            npc:ClearSchedule()
            vTRACE(class.." was running, stopped.")
        elseif not npc:HasCondition(32) and not GetClosestPlayer(npc:GetPos(), MIN_SPAWN_DISTANCE, 0) then
            -- npc can't see the player, there is no player too close, start running towards nearest player
            local ply = GetClosestPlayer(npc:GetPos(), MAX_DISTANCE, MIN_SPAWN_DISTANCE - 100)
            if ply then
                vTRACE(class.." is running to "..ply:Name())
                npc:SetLastPosition(ply:GetPos())
                npc:SetSchedule(SCHED_FORCED_GO_RUN)
            end
        end
    end
end

function CallForHelp(npc)
    if npc:HasCondition(32) or npc:HasCondition(55) then
        local percent = math.random(100)
        if percent <= 40 then FriendlySay(npc, "help01") end
    end
end

function CheckLocation(npc)
    local vStart = npc:EyePos()
    local trace = { }
    trace.start = vStart
    trace.endpos = vStart + Vector(0,0,MAX_DISTANCE)
    trace.filter = npc
    local tr = util.TraceLine(trace)
    if tr.Hit then
        --Trace back down
        local traceBack = { }
        traceBack.start = tr.HitPos
        traceBack.endpos = npc:EyePos()
        traceBack.filter = { }
        table.insert(traceBack.filter, tr.Entity) -- Ignore the entity we hit on the way up
        table.insert(traceBack.filter, npc) -- Ignore the npc itself
        tr = util.TraceLine(traceBack)
        if tr.Hit then
            local Offset = npc:OBBMaxs().z
            local Position = tr.HitPos + Vector(0,0,Offset)
            npc:SetPos(Position)
            vTRACE("REVERSE - Trace hit texture: "..tr.HitTexture.." world: "..tostring(tr.HitWorld).. " entity: "..tr.Entity:GetClass())
            vDEBUG("Moved "..npc:GetClass().." from "..tostring(vStart).." to "..tostring(Position).." offset: "..tostring(Offset))
        end
    end
end
