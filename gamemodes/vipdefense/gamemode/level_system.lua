function GM:OnNPCKilled(victim, ply, inflictor)
    if IsValid(ply) and ply:IsPlayer() then
        local currLevel = GetLevel(ply)
        local currGrade = GetGrade(ply)
        local pointsEarned = GetNpcPointValue(victim)
        if pointsEarned == 0 then Error(ply, victim:GetClass() .. " is worth no points!") end
        if pointsEarned < 1 then return end
        ply:AddFrags(pointsEarned)
        if GetLevel(ply) > currLevel and GetPoints(ply) > 0 then
            level = GetLevel(ply)
            Notify(ply, "You leveled up! You are now level " .. level)
            GivePlayerWeapon(ply)
        else
            MsgPlayer(ply, PointsToNextLevel(ply) .. " more points until level " ..(GetLevel(ply) + 1))
        end
        if GetGrade(ply) > currGrade and GetPoints(ply) > 0 then GiveGradeBonus(ply) end
    end
end

function GivePlayerWeapon(ply)
    tier = GetWeightedRandomTier() + GetGrade(ply)
    print("Debug: Tier = " .. tier)
    if tier >= maxTier then
        GiveSpecial(ply)
    end
    GiveWeaponAndAmmo(ply, GetWeaponForTier(tier))
end

function GetWeaponForTier(tier)
    if tier >= maxTier then return weaponTiers[maxTier] end
    return weaponTiers[tier]
end

function GetTierForWeapon(weapon)
    return weaponTiers[weapon]
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

function GiveWeaponAndAmmo(ply, weaponName)
    -- Num clips is the number of levels beyond your current grade
    -- For example a level 9 with a grade interval of 5 would get 4 (+1) clips
    -- And a level 10 with a grade interval of 5 would get 0 (+1) clips
    numClips =(GetLevel(ply) % GetGradeInterval()) + 1
    if not ply:HasWeapon(weaponName) then
        weapon = ply:Give(weaponName)
    else
        -- Player already has the weapon, give them an extra clip
        weapon = ply:GetWeapon(weaponName)
        numClips = numClips + 1
    end
    ammoType = weapon:GetPrimaryAmmoType()
    clipSize = weapon:GetMaxClip1()
    if clipSize < 1 then clipSize = 1 end
    ammoQuantity = clipSize * numClips
    ply:GiveAmmo(ammoQuantity, ammoType, false)
    MsgPlayer(ply, "You earned a " .. weaponName .. " and " .. numClips .. " clips")
end

function GiveGradeBonus(ply)
    -- npc_alyx
    Notify(ply, "Your skill with weapons increased to Grade " .. GetGrade(ply))
    for i = 0, GetGrade(ply), 1 do
        local bonus = "item_item_crate"
        print("Giving grade bonus to" .. ply:Name() .. " health: " .. ply:Health() .. " armor: " .. ply:Armor())
        if ply:Health() < 100 then
            bonus = "item_healthkit"
        elseif ply:Armor() < 100 then
            bonus = "item_battery"
        elseif GetGrade(ply) > maxTier then
            -- spawn npc ally
        end
        ply:Give(bonus)
    end
end

function GetNpcPointValue(npc)
    local className = npc:GetClass()
    local skill = npc:GetCurrentWeaponProficiency() * 2
    local points = 0
    if className == "npc_headcrab" then
        points = 1
    elseif className == "npc_zombie_torso" then
        points = 1
    elseif className == "npc_barnacle" then
        points = 1
    elseif className == "npc_zombie" then
        points = 2
    elseif className == "npc_manhack" then
        points = 2
    elseif className == "npc_fastzombie_torso" then
        points = 3
    elseif className == "npc_headcrab_fast" then
        points = 3
    elseif className == "npc_headcrab_poison" then
        points = 3
    elseif className == "npc_antlion" then
        points = 3
    elseif className == "npc_fastzombie" then
        points = 5
    elseif className == "npc_stalker" then
        points = 3
    elseif className == "npc_metropolice" then
        points = 1 + skill
    elseif className == "npc_combine_s" then
        points = 4 + skill
    elseif className == "npc_poisonzombie" then
        points = 10
    elseif className == "npc_rollermine" then
        points = 10
    elseif className == "npc_sniper" then
        points = 6 + skill
    elseif className == "npc_vortigaunt" then
        points = 15
    elseif className == "npc_antlionguard" then
        points = 25
    elseif className == "npc_strider" then
        points = 40
    elseif className == "npc_helicopter" then
        points = 40
    elseif className == "npc_combinegunship" then
        points = 50
    end
    print("Debug: NPC className: " .. className .. " worth " .. points.." skill "..skill)
    return points
end
