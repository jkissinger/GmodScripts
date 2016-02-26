--Thinking
local function GetNPCSchedule( npc )
    for s = 0, LAST_SHARED_SCHEDULE-1 do
        if ( npc:IsCurrentSchedule( s ) ) then return s end
    end
    return 0
end

local function LogNPCStatus(npc)
    local name = npc:GetClass()
    VipdLog(vTRACE, name.." state: "..npc:GetNPCState())
    VipdLog(vTRACE, name.." schedule: "..GetNPCSchedule(npc))
    for c = 0, 100 do
        if ( npc:HasCondition( c ) ) then
            VipdLog(vTRACE, name.." has "..npc:ConditionName( c ).." = "..c )
        end
    end
    local caps = npc:CapabilitiesGet()
    if IsBitSet(caps, CAP_AUTO_DOORS) then VipdLog(vTRACE, name.." can open auto doors") end
    if IsBitSet(caps, CAP_OPEN_DOORS) then VipdLog(vTRACE, name.." can open manual doors") end
    if IsBitSet(caps, CAP_MOVE_GROUND ) then VipdLog(vTRACE, name.." can move on the ground") end
    if IsBitSet(caps, CAP_MOVE_FLY ) then VipdLog(vTRACE, name.." can fly") end
    if IsBitSet(caps, CAP_SQUAD ) then VipdLog(vTRACE, name.." can form squads") end
    if IsBitSet(caps, CAP_FRIENDLY_DMG_IMMUNE ) then VipdLog(vTRACE, name.." has friendly fire disabled") end
end

local function SetBehavior(npc)
    local class = npc:GetClass()
    if class == "npc_stalker" and npc:HasCondition(7) and not npc:GetEnemy() then
        npc:SetNPCState(NPC_STATE_COMBAT)
        npc:SetSchedule(SCHED_RANGE_ATTACK1)
    elseif npc:GetNPCState() < NPC_STATE_ALERT then npc:SetNPCState(NPC_STATE_ALERT)
    elseif npc:IsCurrentSchedule(SCHED_ALERT_STAND) or npc:IsCurrentSchedule(SCHED_NONE) then
        local ply = GetClosestPlayer(npc:GetPos(), MaxDistance, 0)
        if ply then
            npc:SetLastPosition(ply:GetPos())
            npc:NavSetGoalTarget( ply, Vector(0,0,0))
            npc:SetSchedule(SCHED_ALERT_WALK)
        end
    end
end

local function CallForHelp(npc)
    if npc:HasCondition(32) or npc:HasCondition(55) then
        local percent = math.random (100)
        if percent <= 25 then CitizenSay(npc, "help01") end
        local ply = GetClosestPlayer (npc:GetPos(), minSpawnDistance - 100, 0)
        if ply then
            npc:SetLastPosition (ply:GetPos () )
            npc:SetSchedule (SCHED_FORCED_GO_RUN)
        end
    end
end

ThinkCounter = 0
CallForHelpInterval = 50
StatusInterval = 10

function VipdThink (ent)
    if not DefenseSystem then return end
    ThinkCounter = ThinkCounter + 1
    if ThinkCounter % StatusInterval == 0 then
        for k, npc in pairs (ents.GetAll ()) do
            if IsValid(npc) and npc:IsSolid() and (npc.isCitizen or npc.isEnemy) then
                if ThinkCounter % CallForHelpInterval == 0 and npc.isCitizen then CallForHelp(npc)
                elseif npc.isCitizen or npc.isEnemy then
                    LogNPCStatus(npc)
                    SetBehavior(npc)
                end
            end
        end
    end
end

hook.Add ("Think", "Vipd think", VipdThink)
