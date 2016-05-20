local function GetNpcPointValue(npcEnt)
    local className = npcEnt:GetClass()
    local skill = npcEnt:GetCurrentWeaponProficiency() * 2
    local weapon = npcEnt:GetActiveWeapon()
    local weaponClass = "none"
    local weaponValue = 0
    if weapon and IsValid(weapon) then
        weaponClass = weapon:GetClass()
    end
    local points = GetPointValue(className, skill, weaponClass)
    vTRACE("NPC className: " .. className .. " worth " .. points .. " skill " .. skill)
    return points
end

local function ProcessKill(ply, points_earned, victim)
    -- Could be false if npc class is undefined
    if points_earned then
        if victim.isTaggedEnemy then
            points_earned = points_earned * 2
            MsgCenter(ply:Name().." killed the tagged enemy for "..points_earned.." points!")
        end
        if PVP_ENABLED:GetBool() then
            AddPoints(ply, points_earned)
        else
            points_earned = math.ceil(points_earned / #player.GetAll())
            for key, player in pairs(player.GetAll()) do
                AddPoints(player, points_earned)
            end
        end
    end
end

local function LevelSystemNpcKill(victim, attacker, inflictor)
    victim.awarded = true
    if IsValid(attacker) and attacker:IsPlayer() then
        local points_earned = GetNpcPointValue(victim)
        if points_earned < 0 then
            MsgCenter(attacker:Name().. " killed a good guy and lost "..(-1 * points_earned).." points!")
        end
        ProcessKill(attacker, points_earned, victim)
    end
end

local function LevelSystemPlayerKill(victim, inflictor, attacker)
    if IsValid(attacker) and attacker:IsPlayer() and victim:IsPlayer() then
        local points_earned = 0
        if victim:Name() == attacker:Name() then
            points_earned = -1 * math.floor(GetAvailablePoints(victim)/10)
        else
            points_earned = math.floor(GetAvailablePoints(victim)/10)
            if points_earned < 10 then points_earned = 10 end
        end
        MsgCenter(attacker:Name().." killed "..victim:Name().." for "..points_earned.." points!")
        ProcessKill(attacker, points_earned, victim)
    end
end

--Capture the last player to attack the entity
local function TrackEntityDamage(target, dmg)
    local attacker = dmg:GetAttacker()
    if attacker and IsValid(attacker) and target:IsNPC() then
        if attacker:IsPlayer() then
            target.lastAttacker = attacker
            vTRACE(attacker:Name().." damaged "..target:GetClass())
        else
            --vINFO(attacker:GetClass().." damaged "..target:GetClass())
            target.lastAttacker = nil
        end
    end
end

local function TrackEntityRemoval(entity)
    if entity:IsNPC() then
        if not entity.awarded then
            if entity.lastAttacker then
                BrodcastNotify("Awarding kill of  "..entity:GetClass().." to: "..entity.lastAttacker:Name())
                LevelSystemNpcKill(entity, entity.lastAttacker, nil)
            else
            --vWARN("NPC removed without last attacker: "..entity:GetClass())
            end
        end
    else
    --        vINFO("Removed non-NPC entity: " .. entity:GetClass())
    end
end

hook.Add( "PlayerDeath", "VipdPlayerKilled", LevelSystemPlayerKill)
hook.Add( "OnNPCKilled", "VipdLevelNpcKilled", LevelSystemNpcKill)
hook.Add( "EntityTakeDamage", "VipdEntityTakeDamage", TrackEntityDamage)
hook.Add( "EntityRemoved", "VipdEntityRemoved", TrackEntityRemoval)
