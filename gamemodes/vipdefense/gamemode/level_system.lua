function GM:OnNPCKilled(victim, ply, inflictor)
    -- TODO check if the npc killed itself, if so give credit to the last attacker/current enemy?
    if IsValid(ply) and ply:IsPlayer() then
        local currLevel = GetLevel(ply)
        local currGrade = GetGrade(ply)
        local pointsEarned = GetNpcPointValue(victim)
        if pointsEarned < 0 then Error(ply, victim:GetClass() .. " has no points defined!") end
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
    if tier > MaxTier then
        GiveSpecial(ply)
    end
    GiveWeaponAndAmmo(ply, GetWeaponForTier(tier))
end

function GetWeaponForTier(tier)
    if tier > MaxTier then tier = MaxTier end
    for className, weapon in pairs(vipd_weapons) do
        if weapon.value == tier then
            weapon.className = className
            return weapon
        end
    end
end

function GetTierForWeapon(weapon)
    return vipd_weapons[weapon].value
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

function GiveWeaponAndAmmo(ply, weapon)
    -- Num clips is the number of levels beyond your current grade
    -- For example a level 9 with a grade interval of 5 would get 4 (+1) clips
    -- And a level 10 with a grade interval of 5 would get 0 (+1) clips
    numClips =(GetLevel(ply) % GetGradeInterval()) + 1
    if not ply:HasWeapon(weapon.className) then
        weaponEnt = ply:Give(weapon.className)
    else
        -- Player already has the weapon, give them an extra clip
        weaponEnt = ply:GetWeapon(weapon.className)
        numClips = numClips + 1
    end
    ammoType = weaponEnt:GetPrimaryAmmoType()
    clipSize = weaponEnt:GetMaxClip1()
    if clipSize < 1 then clipSize = 1 end
    ammoQuantity = clipSize * numClips
    ply:GiveAmmo(ammoQuantity, ammoType, false)
    Notify(ply, "You earned a " .. weapon.name .. " and " .. numClips .. " clips.")
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
        elseif GetGrade(ply) > MaxTier then
            -- spawn npc ally
        end
        ply:Give(bonus)
    end
end

function GetNpcPointValue(npcEnt)
    local className = npcEnt:GetClass()
    local npc = vipd_npcs[className]
    local points = 0
    -- skill isn't used yet
    -- also need to check weapons
    local skill = npcEnt:GetCurrentWeaponProficiency() * 2
    local weapon = npcEnt:GetActiveWeapon()
    if npc == nil then
        points = -1
    else
        points = vipd_npcs[className].value
        if not weapon == nil then
            local weaponClass = weapon:GetClass()
            points = points + vipd_weapons[weaponClass].npcValue
        end
    end
    print("Debug: NPC className: " .. className .. " worth " .. points .. " skill " .. skill)
    return points
end

function GetNpcName(npc)
    local className = npc:GetClass()
    local name = vipd_vipd_npcs[className].name
    if name == nil then name = className end
    return name
end