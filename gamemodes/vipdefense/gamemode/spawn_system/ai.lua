local function SetBehavior(npc)
    if npc.isFriendly then
        local ply = GetClosestPlayer(npc:GetPos(), minSpawnDistance - 100, 0)
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
        elseif npc:IsCurrentSchedule(SCHED_FORCED_GO_RUN) and (npc:HasCondition(32) or GetClosestPlayer(npc:GetPos(), minSpawnDistance, 0)) then
            -- npc is running, but they can see a player or are too close, stop running
            npc:ClearSchedule()
            vTRACE(class.." was running, stopped.")
        elseif not npc:HasCondition(32) and not GetClosestPlayer(npc:GetPos(), minSpawnDistance, 0) then
            -- npc can't see the player, there is no player too close, start running towards nearest player
            local ply = GetClosestPlayer(npc:GetPos(), MaxDistance, minSpawnDistance - 100)
            if ply then
                vTRACE(class.." is running to "..ply:Name())
                npc:SetLastPosition(ply:GetPos())
                npc:SetSchedule(SCHED_FORCED_GO_RUN)
            end
        end
    end
end

local function CallForHelp(npc)
    -- Call for help if friendly can see or hear player
    if npc:HasCondition(32) or npc:HasCondition(55) then
        local percent = math.random(100)
        if percent <= 40 then FriendlySay(npc, "help01") end
    end
end

local function CheckLocation(npc)
    local vStart = npc:EyePos()
    local trace = { }
    trace.start = vStart
    trace.endpos = vStart + Vector(0,0,MaxDistance)
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

local function CheckTaggedEnemy(npc, tag_enemy)
    if tag_enemy then npc.isTaggedEnemy = true end
    if npc.isTaggedEnemy then TAGGED_ENEMY = npc end
    return false
end

local function RemoveRagdolls()
    local models = { }
    models["models/combine_strider.mdl"] = true
    for key, entity in pairs(ents.GetAll()) do
        if entity:GetClass() == "prop_ragdoll" and models[entity:GetModel()] then
            entity:Remove()
        end
        if entity:GetClass() == "prop_ragdoll" and entity:IsSolid() then
            vTRACE("Solid ragdoll found removing it: "..entity:GetModel())
            --entity:Remove()
        end
    end
end

--===========--
--Spawn Logic--
--===========--

local function CalculateMaxNpcs()
    local maxPer = NpcsPerPlayer * #player.GetAll()
    if maxPer > MaxNpcs then
        return MaxNpcs
    else
        return maxPer
    end
end

local function CheckNpcs()
    local maxNpcs = CalculateMaxNpcs()
    vTRACE("Checking npcs, total: "..maxNpcs.." current: "..CurrentNpcs)
    if CurrentNpcs < maxNpcs then
        if #vipd.Nodes < 1 then return end
        local node = GetNextNode()
        if node then
            local npc = SpawnNpc(node)
            if npc then
                CurrentNpcs = CurrentNpcs + 1
            else
                vWARN("Spawning NPC failed!")
            end
        else
            vWARN("No valid NPC nodes found!")
        end
    end
end

--local ThinkCounter = 0
-- Generic
local HudCounter = 0
local HudUpdate = 10
--Level system
local LevelSystemCounter = 0
local SavePosInterval = 75
--Defense system
local DefenseSystemCounter = 0
local ThinkInterval = 20
local CallForHelpInterval = 40
local LocationInterval = 100
local CheckNpcInterval = 120
local RagdollRemoval = 500

local function VipdThink(ent)
    -- Hud functions
    HudCounter = HudCounter + 1
    if HudCounter % HudUpdate == 0 then VipdHudUpdate() end
    -- Level system
    if LevelSystem then
        LevelSystemCounter = LevelSystemCounter + 1
        if LevelSystemCounter % SavePosInterval == 0 then
            for k, ply in pairs(player.GetAll()) do
                local vply = GetVply(ply:Name())
                vply.PreviousPos2 = vply.PreviousPos1
                vply.PreviousPos1 = ply:GetPos()
            end
        end
    end
    -- Defense system
    if DefenseSystem then
        DefenseSystemCounter = DefenseSystemCounter + 1
        if DefenseSystemCounter % ThinkInterval == 0 then
            local tag_enemy = not TAGGED_ENEMY
            TAGGED_ENEMY = nil
            local total_current_enemies = 0
            for k, npc in pairs(GetVipdNpcs()) do
                local is_valid_npc = npc and IsValid(npc) and npc:IsSolid() and npc:IsNPC()
                local is_valid_vipd_npc = is_valid_npc and (npc.isEnemy or npc.isFriendly)
                if is_valid_vipd_npc then
                    SetBehavior(npc)
                    if npc.isEnemy then
                        tag_enemy = CheckTaggedEnemy(npc, tag_enemy)
                        total_current_enemies = total_current_enemies + 1
                    end
                    if DefenseSystemCounter % CallForHelpInterval == 0 and npc.isFriendly then CallForHelp(npc) end
                    if DefenseSystemCounter % LocationInterval == 0 then CheckLocation(npc) end
                end
            end
            CurrentNpcs = total_current_enemies
            if DefenseSystemCounter % CheckNpcInterval == 0 then CheckNpcs() end
            if DefenseSystemCounter % RagdollRemoval == 0 then RemoveRagdolls() end
        end
    end
end

hook.Add("Think", "Vipd think", VipdThink)
