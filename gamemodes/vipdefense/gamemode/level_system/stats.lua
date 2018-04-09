function GetDefaultStats()
    return { deaths = 0, suicides = 0, enemy_damage_dealt = 0, friendly_damage_dealt = 0, player_damage_dealt = 0, enemy_npcs_killed = 0, friendly_npcs_killed = 0, players_killed = 0 }
end

local function VipdStatsPlayerDeath(victim, inflictor, attacker)
    if IsValid(victim) and victim:IsPlayer() then
        local vattacker = GetVplyByPlayer(attacker)
        if vattacker then
            vattacker.stats.players_killed = vattacker.stats.players_killed + 1;
        end
        local vvictim = GetVplyByPlayer(victim)
        if vvictim then
            vvictim.stats.deaths = vvictim.stats.deaths + 1;
            if vvictim == vattacker then
                vvictim.stats.suicides = vvictim.stats.suicides + 1;
            end
        end
    end
end

local function VipdStatsOnNPCKilled(victim, attacker, inflictor)
    local vply = GetVplyByPlayer(attacker)
    if vply then
        if IsFriendly(victim, attacker) then
            vply.stats.friendly_npcs_killed = vply.stats.friendly_npcs_killed + 1;
        else
            vply.stats.enemy_npcs_killed = vply.stats.enemy_npcs_killed + 1;
        end
    end
end

local function VipdStatsEntityTakeDamage(target, dmginfo)
    local attacker = dmginfo:GetAttacker()
    local vply = GetVplyByPlayer(attacker)
    if vply then
        local damage_dealt = dmginfo:GetDamage()
        if damage_dealt > target:Health() then
            damage_dealt = target:Health()
        end
        if target:IsNPC() and damage_dealt > 0 then
            if IsFriendly(target, attacker) then
                vply.stats.friendly_damage_dealt = vply.stats.friendly_damage_dealt + damage_dealt;
            else
                vply.stats.enemy_damage_dealt = vply.stats.enemy_damage_dealt + damage_dealt;
            end
        elseif target:IsPlayer() and damage_dealt > 0 then
            vply.stats.player_damage_dealt = vply.stats.player_damage_dealt + damage_dealt;
        end
    end
end

hook.Add("PlayerDeath", "VipdStatsPlayerDeath", VipdStatsPlayerDeath)
hook.Add("OnNPCKilled", "VipdStatsOnNPCKilled", VipdStatsOnNPCKilled)
hook.Add("EntityTakeDamage", "VipdStatsEntityTakeDamage", VipdStatsEntityTakeDamage)