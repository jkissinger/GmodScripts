function SetBehavior(npc)
    if IsAlly(npc) then
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

function AllySay(npc, sound_type)
    local sound = ""
    local npc_model = npc:GetModel()
    local npc_data = GetNpcData(npc)

    local base_sound_dir = "vo/npc/male01/"
    if string.match(npc_model, "female") then base_sound_dir = "vo/npc/female01/" end
    
    local custom_sound_dir = "vo/"
    local npc_sound = custom_sound_dir .. npc_data.gmod_class

    if sound_type == SOUND_TYPE_HELP then
        local help_sound = npc_sound .. HELP_SOUND_EXTENSION
        if file.Exists("sound/" .. help_sound, "GAME") then
            sound = help_sound
        else
            vINFO(help_sound .. " did not exist!")
            sound = base_sound_dir.."help01.wav"
        end
    elseif sound_type == SOUND_TYPE_RESCUE then
        local rescue_sound = npc_sound .. RESCUE_SOUND_EXTENSION
        if file.Exists("sound/" .. rescue_sound, "GAME") then
            sound = rescue_sound
        else
            vINFO(rescue_sound .. " did not exist!")
            sound = base_sound_dir.."health0"..math.random(5)..".wav"
        end
    end

    if sound == "" then
        vINFO(npc_data.name.." should have said something (" .. sound_type ..") but didn't!")
    else
        vDEBUG(npc_data.name.." is saying "..sound)
        npc:EmitSound(sound, SNDLVL_95dB, 100, 1, CHAN_VOICE)
        vDEBUG("Condition: "..npc:GetNPCState())
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
