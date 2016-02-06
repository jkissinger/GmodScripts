function GM:OnNPCKilled(victim, attacker, inflictor)
    if IsValid(attacker) and attacker:IsPlayer() then
        attacker:AddFrags(1)
        if (attacker:Frags() % GetLevelInterval() == 0) then
            level = GetLevel(attacker)
            Notify(attacker, "You leveled up! You are now level " .. level)
            GivePlayerWeapon(attacker)
        else
            MsgPlayer(attacker, KillsToNextLevel(attacker) .. " more kills until level " ..(GetLevel(attacker) + 1))
        end
    end
end

function GetGrade(ply)
    return math.floor(GetLevel(ply) / GetGradeInterval())
end

function GetLevel(ply)
    return math.floor(ply:Frags() / GetLevelInterval())
end

function KillsToNextLevel(ply)
    return GetLevelInterval() - ply:Frags() % GetLevelInterval()
end

function LevelsToNextGrade(ply)
    return GetGradeInterval() - GetLevel(ply) % GetGradeInterval()
end

function MsgPlayer(ply, msg)
    ply:PrintMessage(HUD_PRINTTALK, msg)
end

util.AddNetworkString("gmod_notification")

function Notify(ply, msg)
    net.Start("gmod_notification")
    net.WriteString(msg)
    net.Send(ply)
end

function GetLevelInterval()
    return GetConVarNumber("vipd_killsperlevel")
end

function GetGradeInterval()
    return GetConVarNumber("vipd_killsperlevel")
end

maxTier = 8

function GivePlayerWeapon(ply, level)
    tier = GetTier() + GetGrade(ply)
    print("Debug: Tier = " .. tier)
    weapon = "weapon_pistol"
    if tier == 2 then
        weapon = "weapon_smg1"
    elseif tier == 3 then
        weapon = "weapon_shotgun"
    elseif tier == 4 then
        weapon = "weapon_357"
    elseif tier == 5 then
        weapon = "weapon_ar2"
    elseif tier == 6 then
        weapon = "weapon_frag"
    elseif tier == 7 then
        weapon = "weapon_crossbow"
    elseif tier >= maxTier then
        weapon = "weapon_crossbow"
        GiveSpecial(ply)
    end
    GiveWeaponAndAmmo(ply, weapon)
end

function GiveSpecial(ply)
    chance = math.random(1, 3)
    if chance == 1 then
        special = "item_ammo_ar2_altfire"
    elseif chance == 2 then
        special = "item_ammo_smg1_grenade"
    elseif chance == 3 then
        ply:Give("weapon_rpg")
        special = "item_rpg_round"
    end
    MsgPlayer(ply, "You were given a special bonus! An " .. special)
    ply:Give(special)
end

function GetTier()
    chance = math.random(1, 15)
    if chance <= 8 then
        return 1
    elseif chance <= 12 then
        return 2
    elseif chance <= 14 then
        return 3
    elseif chance == 15 then
        return 4
    end
end

function GiveWeaponAndAmmo(ply, weaponName)
    -- Num clips is the number of levels beyond your current grade
    -- For example a level 9 with a grade interval of 5 would get 4 (+1) clips
    -- And a level 10 with a grade interval of 5 would get 0 (+1) clips
    numClips =(GetLevel(ply) % GetGradeInterval()) + 1
    if not ply:HasWeapon(weaponName) then
        weapon = ply:Give(weaponName)
    else
        weapon = ply:GetWeapon(weaponName)
        -- Player already has the weapon, give them an extra clip
        numClips = numClips + 1
    end
    ammoType = weapon:GetPrimaryAmmoType()
    clipSize = weapon:GetMaxClip1()
    if clipSize < 1 then clipSize = 1 end
    ammoQuantity = clipSize * numClips
    ply:GiveAmmo(ammoQuantity, ammoType, false)
    MsgPlayer(ply, "You earned a " .. weaponName .. " and " .. numClips .. " clips")
    if GetLevel(ply) % GetGradeInterval() == 0 then
        Notify(ply, "Your skill with weapons increased to Grade " .. GetGrade(ply))
        for i = 0, GetGrade(ply), 1 do
            GiveGradeBonus(ply)
        end
    end
end

function GiveGradeBonus(ply)
    -- npc_alyx
    local bonus = "item_item_crate"
    if ply:Health() < 100 then
        bonus = "item_healthkit"
    elseif ply:Armor() < 100 then
        bonus = "item_battery"
    elseif GetGrade(ply) > maxTier then
        -- spawn npc ally
    end
    ply:Give(bonus)
end