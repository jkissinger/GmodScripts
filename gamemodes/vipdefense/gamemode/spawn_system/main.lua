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
    if CurrentNpcs < 5 then
        vINFO("Spawning next group in 5 seconds")
        timer.Simple(5, VipdSpawnNpcs)
    end
end

function VipdSpawnNpcs()
    local maxNpcs = CalculateMaxNpcs()
    vDEBUG("Spawning new NPCs, currently: "..CurrentNpcs.." Max: "..maxNpcs)
    for i = CurrentNpcs + 1, maxNpcs do
        if not DefenseSystem or #vipd.Nodes == 0 then return end
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

--==============--
--Initialization--
--==============--

local function ResetMap()
    InitSystemGlobals()
    NextNodes = { }
    UsedNodes = { }
    game.CleanUpMap(false, {} )
    for k, ply in pairs(player.GetAll()) do
        ResetVply(ply:Name())
        ply:SetHealth(100)
        ply:SetArmor(0)
        VipdLoadout(ply)
    end
end

local function DefenseSystemKillConfirm(victim, ply, inflictor)
    if DefenseSystem and (victim.isEnemy or victim.isFriendly) then
        CurrentNpcs = CurrentNpcs - 1
        if victim.isEnemy then DeadEnemies = DeadEnemies + 1 end
        if victim.isFriendly then
            if IsValid(ply) and ply:IsPlayer() then
                BroadcastNotify(ply:Name().." killed a "..VipdFriendlyTeam.."!")
                AddPoints(ply, -50)
            end
            DeadFriendlys = DeadFriendlys + 1
        end
        if #vipd.Nodes > 0 then
            CheckNpcs()
        elseif CurrentNpcs == 0 then
            MsgCenter("You have successfully held off the invasion on "..game.GetMap().."!")
            DefenseSystem = false
        end
    end
end

function InitDefenseSystem( ply )
    if DefenseSystem then return end
    if IsValid(ply) then
        ResetMap()
        GetNodes()
        if #vipd.Nodes < 50 then
            DefenseSystem = false
            BroadcastError("Can't init invasion because "..game.GetMap().." has less than 50 AI nodes!")
        else
            DefenseSystem = true
            MsgCenter("Initializing invasion.")
            CheckNpcs()
        end
    end
end

function StopDefenseSystem()
    MsgCenter("Shutting down invasion.")
    DefenseSystem = false
    ResetMap()
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

function GetFriendlies()
    local friendlies = { }
    for key, ent in pairs(ents.GetAll()) do
        if ent.isFriendly then table.insert(friendlies, ent) end
    end
    return friendlies
end

function GetEnemies()
    local enemies = { }
    for key, ent in pairs(ents.GetAll()) do
        if ent.isEnemy then table.insert(enemies, ent) end
    end
    return enemies
end

function GetVipdNpcs()
    local npcs = { }
    for key, ent in pairs(ents.GetAll()) do
        if ent.isEnemy or ent.isFriendly then table.insert(npcs, ent) end
    end
    return npcs
end

--=================--
--Rescuing Friendly--
--=================--

local function Rescue(ply, ent)
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
    Notify(ply, "You rescued a ".. VipdFriendlyTeam .."!")
    AddPoints(ply, FriendlyPointValue)
    GiveBonuses(ply, 1)
    CurrentNpcs = CurrentNpcs - 1
    RescuedFriendlys = RescuedFriendlys + 1
    CheckNpcs()
end

function GM:FindUseEntity(ply, ent)
    if ent.isFriendly then
        Rescue(ply, ent)
    else
        return ent
    end
end



hook.Add( "OnNPCKilled", "VipdDefenseNPCKilled", DefenseSystemKillConfirm)
