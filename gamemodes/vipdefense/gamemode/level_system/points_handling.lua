local function GetNpcAndWeaponData(NPC)
    local skill = NPC:GetCurrentWeaponProficiency()
    local npc_data = GetNpcData(NPC)
    if npc_data == nil then
        vWARN("Unable to find NPC data: " .. tostring(NPC))
        return
    end
    local weapon = NPC:GetActiveWeapon()
    local weapon_data = { class = "none", value = 0 }
    if weapon and IsValid(weapon) then
        weapon_data.class = weapon:GetClass()
        if vipd_weapons[weapon_data.class] then
            weapon_data.value = vipd_weapons[weapon_data.class].npcValue
        else
            vINFO(npc_data.name .. " had undefined weapon '" .. weapon_data.class .. "'")
        end
    end
    if npc_data.value < 0 then
        weapon_data.value = weapon_data.value * -1
    end
    return npc_data, weapon_data
end

local function TagNewEnemy(oldEnemy)
    local closestEnemy
    local closestDistance = MAX_DISTANCE
    for k, npc in pairs(GetVipdNpcs()) do
        if IsAlive(npc) then
            if IsEnemy(npc) then
                local distance = npc:GetPos():Distance(oldEnemy:GetPos())
                if distance < closestDistance then
                    closestDistance = distance
                    closestEnemy = npc
                end
            end
        end
    end
    if closestEnemy then
        closestEnemy.isTaggedEnemy = true
    end
end

local function ProcessKill(ply, points_earned, victim)
    if victim.isTaggedEnemy then
        points_earned = points_earned * 2
        MsgCenter(ply:Name() .. " killed the tagged enemy for double points (" .. points_earned .. ")!")
        TagNewEnemy(victim)
    end
    if PvpEnabled or points_earned < 0 then
        AddPoints(ply, points_earned)
    else
        points_earned = math.ceil(points_earned / #player.GetAll())
        if points_earned == 0 then
            points_earned = 1
        end
        for key, player in pairs(player.GetAll()) do
            AddPoints(player, points_earned)
        end
    end
end

local function LevelSystemKillConfirm(victim, attacker, inflictor)
    victim.awarded = true
    if IsValid(attacker) and attacker:IsPlayer() and not CalibrationEnabled then
        local npc_data, weapon_data = GetNpcAndWeaponData(victim)
        if npc_data == nil or weapon_data == nil then
            return
        end
        local points_earned = npc_data.value + weapon_data.value
        if IsFriendly(victim, attacker) then
            points_earned = points_earned * -1
            MsgCenter(attacker:Name() .. " killed a good guy and lost " .. points_earned .. " points!")
        end
        ProcessKill(attacker, points_earned, victim)
        local msg = " killed " .. npc_data.name .. " worth " .. npc_data.value
        if weapon_data.class ~= "none" then
            msg = msg .. " with a " .. weapon_data.class .. " worth " .. weapon_data.value
        end
        --msg = msg .. " Disposition: " .. GetDispositionString(victim, attacker)
        msg = msg .. " MaxHealth: " .. victim:GetMaxHealth()
        Notify(attacker, "You" .. msg)
        vDEBUG(attacker:Name() .. msg)
    end
end

local function LevelSystemDamageTaken(target, dmginfo)
    local attacker = dmginfo:GetAttacker()
    if target:IsNPC() and IsValid(attacker) and attacker:IsPlayer() and not CalibrationEnabled then
        target.awarded = true
        local points_earned = dmginfo:GetDamage()
        if points_earned > target:Health() then
            points_earned = target:Health()
        end
        if points_earned < 0 then
            -- This likely means the target was already dead
            return
        end
        if IsFriendly(target, attacker) then
            points_earned = points_earned * -1
            MsgCenter(attacker:Name() .. " killed a good guy and lost " .. points_earned .. " points!")
        end
        ProcessKill(attacker, points_earned, target)
        local msg = " did [" .. points_earned .. "] damage to " .. target:GetName() .. " (" .. target:GetModel() .. ")"
        --Notify(attacker, "You" .. msg)
        vDEBUG(attacker:Name() .. msg)
    end
end

local function LevelSystemPlayerKill(victim, inflictor, attacker)
    if IsValid(attacker) and attacker:IsPlayer() and victim:IsPlayer() and attacker ~= victim then
        local points_earned = 0
        if victim:Name() == attacker:Name() then
            points_earned = -1 * math.floor(GetAvailablePoints(victim) / 10)
        else
            points_earned = math.floor(GetAvailablePoints(victim) / 10)
            if points_earned < 10 then
                points_earned = 10
            end
        end
        MsgCenter(attacker:Name() .. " killed " .. victim:Name() .. " for " .. points_earned .. " points!")
        ProcessKill(attacker, points_earned, victim)
    end
end

--Capture the last player to attack the entity
local function TrackEntityDamage(target, dmg)
    local attacker = dmg:GetAttacker()
    if attacker and IsValid(attacker) and target:IsNPC() then
        if attacker:IsPlayer() then
            target.lastAttacker = attacker
            vTRACE(attacker:Name() .. " damaged " .. target:GetClass())
        else
            target.lastAttacker = nil
        end
    end
end

local function TrackEntityRemoval(entity)
    if entity:IsNPC() then
        if not entity.awarded then
            if entity.lastAttacker then
                BroadcastNotify("Awarding kill of  " .. entity:GetClass() .. " to: " .. entity.lastAttacker:Name())
                LevelSystemKillConfirm(entity, entity.lastAttacker, nil)
            end
        end
    end
end

hook.Add("PlayerDeath", "VipdPlayerKilled", LevelSystemPlayerKill)
--hook.Add( "OnNPCKilled", "VipdLevelNpcKilled", LevelSystemKillConfirm)
--hook.Add( "EntityTakeDamage", "VipdEntityTakeDamage", TrackEntityDamage)
-- The 2 hooks above are exclusive with the one below
hook.Add("EntityTakeDamage", "VipdEntityTakeDamage", LevelSystemDamageTaken)
hook.Add("EntityRemoved", "VipdEntityRemoved", TrackEntityRemoval)
