local function GetVipdNpcByClass(EntClass)
    if vipd_npcs[EntClass] then return vipd_npcs[EntClass] end
    for key, npc in pairs(vipd_npcs) do
        if npc.class == EntClass then return npc end
    end
end

local function GetNpcData(NPC, Skill)
    local npc_model = NPC:GetModel()
    local npc_data = NpcsByModel[npc_model]
    local npc_class = NPC:GetClass()
    if not npc_data then npc_data = GetVipdNpcByClass(npc_class) end
    if not npc_data then
        npc_data = { name = npc_class, value = 0}
        vWARN("NPC class: ".. npc_class .. " is not defined in the config!")
    end
    return npc_data
end

local function GetNpcAndWeaponData(NPC)
    local skill = NPC:GetCurrentWeaponProficiency()
    local npc_data = GetNpcData(NPC, skill)
    local weapon = NPC:GetActiveWeapon()
    local weapon_data = { class = "none", value = 0}
    if weapon and IsValid(weapon) then
        weapon_data.class = weapon:GetClass()
        if vipd_weapons[weapon_data.class] then
            weapon_data.value = vipd_weapons[weapon_data.class].npcValue
        else
            vDEBUG(npc_data.name .. " had undefined weapon '" .. weapon_data.class .. "'")
        end
    end
    if npc_data.value < 0 then weapon_data.value = weapon_data.value * -1 end
    return npc_data, weapon_data
end

local function ProcessKill(ply, points_earned, victim)
    if victim.isTaggedEnemy then
        points_earned = points_earned * 2
        MsgCenter(ply:Name().." killed the tagged enemy for double points (" .. points_earned .. ")!")
    end
    if PVP_ENABLED:GetBool() or points_earned < 0 then
        AddPoints(ply, points_earned)
    else
        points_earned = math.ceil(points_earned / #player.GetAll())
        for key, player in pairs(player.GetAll()) do
            AddPoints(player, points_earned)
        end
    end
end

local function LevelSystemNpcKill(victim, attacker, inflictor)
    victim.awarded = true
    if IsValid(attacker) and attacker:IsPlayer() then
        local npc_data, weapon_data = GetNpcAndWeaponData(victim)
        local points_earned = npc_data.value + weapon_data.value
        if points_earned < 0 then
            MsgCenter(attacker:Name().. " killed a good guy and lost ".. points_earned .." points!")
        end
        ProcessKill(attacker, points_earned, victim)
        local msg = " killed " .. npc_data.name .. " worth " .. npc_data.value .. " with a " .. weapon_data.class .. " worth " .. weapon_data.value
        Notify(attacker, "You" .. msg)
        vDEBUG(attacker:Name() .. msg)
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
            target.lastAttacker = nil
        end
    end
end

local function TrackEntityRemoval(entity)
    if entity:IsNPC() then
        if not entity.awarded then
            if entity.lastAttacker then
                BroadcastNotify("Awarding kill of  "..entity:GetClass().." to: "..entity.lastAttacker:Name())
                LevelSystemNpcKill(entity, entity.lastAttacker, nil)
            end
        end
    end
end

hook.Add( "PlayerDeath", "VipdPlayerKilled", LevelSystemPlayerKill)
hook.Add( "OnNPCKilled", "VipdLevelNpcKilled", LevelSystemNpcKill)
hook.Add( "EntityTakeDamage", "VipdEntityTakeDamage", TrackEntityDamage)
hook.Add( "EntityRemoved", "VipdEntityRemoved", TrackEntityRemoval)
