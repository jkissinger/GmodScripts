local function GetNpcPointValue(npcEnt)
    local className = npcEnt:GetClass()
    local skill = npcEnt:GetCurrentWeaponProficiency() * 2
    local weapon = npcEnt:GetActiveWeapon()
    local weaponClass = "none"
    local weaponValue = 0
    if weapon and IsValid(weapon) then
        weaponClass = weapon:GetClass()
    end
    points = GetPointValue(weaponClass, skill, className)
    VipdLog(vTRACE, "NPC className: " .. className .. " worth " .. points .. " skill " .. skill)
    return points
end

local function VipdNpcKilled(victim, ply, inflictor)
    if IsValid(ply) and ply:IsPlayer() then
        local pointsEarned = GetNpcPointValue(victim)
        if pointsEarned < 0 then BroadcastError(ply, victim:GetClass() .. " has no points defined!") end
        if pointsEarned >= 1 then
            AddPoints(ply, pointsEarned)
        end
    end
    if DefenseSystem and (victim.isEnemy or victim.isFriendly) then
        currentNpcs = currentNpcs - 1
        if victim.isEnemy then DeadEnemies = DeadEnemies + 1 end
        if victim.isFriendly then
            if IsValid(ply) and ply:IsPlayer() then
                BroadcastNotify(ply:Name().." killed a "..VipdFriendlyTeam.."!")
                AddPoints(ply, -50)
            end
            DeadFriendlys = DeadFriendlys + 1
        end
        if #vipd.Nodes > 0 then CheckNpcs() end
    end
end

function AddPoints(ply, points)
    local currLevel = GetLevel(ply)
    local currGrade = GetGrade(ply)
    SetPoints(ply, GetActualPoints(ply) + points)
    local newLevel = GetLevel(ply)

    for level = currLevel+1, newLevel do
        Notify(ply, "You leveled up! You are now level " .. level)
        local grade = GetGradeForLevel(level)
        GivePlayerWeapon(ply, level, grade)
    end

    if GetGrade(ply) > currGrade and GetPoints(ply) > 0 then
        Notify(ply, "Your skill with weapons increased to Grade " .. GetGrade(ply))
        GiveBonuses(ply, 1)
    end

    ply:SetFrags(newLevel)
end

local function GetWeaponForTier(tier)
    if tier > MaxTier then tier = MaxTier end
    for className, weapon in pairs(vipd_weapons) do
        if weapon.tier == tier then
            VipdLog(vTRACE, "Tier = " .. tier.." Weapon tier: "..weapon.tier)
            weapon.className = className
            return weapon
        end
    end
end

local function GiveWeaponAndAmmo(ply, weapon, clips)
    -- Num clips is the number of levels beyond your current grade
    -- For example a level 9 with a grade interval of 5 would get 4 (+1) clips
    -- And a level 10 with a grade interval of 5 would get 0 (+1) clips
    if not ply:HasWeapon(weapon.className) then
        weaponEnt = ply:Give(weapon.className)
    else
        -- Player already has the weapon, give them an extra clip
        weaponEnt = ply:GetWeapon(weapon.className)
        clips = clips + 1
    end
    ammoType = weaponEnt:GetPrimaryAmmoType()
    clipSize = weaponEnt:GetMaxClip1()
    if clipSize < 1 then clipSize = 1 end
    ammoQuantity = clipSize * clips
    ply:GiveAmmo(ammoQuantity, ammoType, false)
end

local function GetWeightedRandomTier()
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

function GivePlayerWeapon(ply, level, grade)
    tier = GetWeightedRandomTier() + grade
    if tier > MaxTier then
        GiveBonuses(ply, GetGrade(ply) - MaxTier)
    end
    --Give player weapon they earned
    GiveWeaponAndAmmo(ply, GetWeaponForTier(tier), 2)
    --Give player each of the previous tier weapons, and 3 clips
    for i = 1, grade - 1, 1 do
        local Weapon = GetWeaponForTier(i)
        GiveWeaponAndAmmo(ply, Weapon, 3)
    end
end

local function GetSpecial()
    chance = math.random(1, 3)
    if chance == 1 then
        special = "item_ammo_ar2_altfire"
    elseif chance == 2 then
        special = "item_ammo_smg1_grenade"
    elseif chance == 3 then
        special = "item_rpg_round"
    end
    return special
end

local function GiveBonus(tempPly)
    local bonus = GetSpecial()
    if tempPly.Health < 100 then
        bonus = "item_healthkit"
        tempPly.Health = tempPly.Health + 25
    elseif tempPly.Armor < 100 then
        bonus = "item_battery"
        tempPly.Armor = tempPly.Armor + 25
    elseif tempPly.Grade > MaxTier then
        bonus = GetSpecial()
        -- spawn npc ally?
    end
    return bonus
end

function GiveBonuses(ply, num)
    local tempPly = { }
    tempPly.Health = ply:Health()
    tempPly.Armor = ply:Armor()
    tempPly.Grade = GetGrade(ply)
    for i = 1, num do
        local bonus = GiveBonus(tempPly)
        VipdLog(vTRACE, "Giving bonus of "..bonus.." to " .. ply:Name() .. " temphealth: " .. tempPly.Health .. " temparmor: " .. tempPly.Armor)
        ply:Give(bonus)
    end
end

function GetPointValue(WeaponClass, Skill, EntClass)
    local npc = vipd_npcs[EntClass]
    if npc == nil then return -1 end
    return npc.value + vipd_weapons[WeaponClass].npcValue
end

function SetHandicap(ply, cmd, arguments)
    if not arguments [1] or not arguments [2] then
        local t = { }
        for k, ply in pairs(player.GetAll()) do
            local p = { }
            p.ply = ply
            local vply = GetVply(ply:Name())
            p.handicap = vply.handicap
            p.actualPoints = GetActualPoints(ply)
            p.points = GetPoints(ply)
            table.insert(t, p)
        end
        PrintTable (t)
    else
        local ply = VipdGetPlayer(arguments[1])
        local handicap = tonumber(arguments[2])
        if not ply then
            VipdLog (vWARN, "Unable to find player: "..arguments[1])
        elseif not handicap then
            VipdLog (vWARN, "Invalid handicap: "..arguments[2])
        else
            local vply = GetVply(ply:Name())
            vply.handicap = handicap
        end
    end
end

--==================--
--Teleport Functions--
--==================--

function TeleportToLastPos(ply, cmd, arguments)
    if not arguments [1] then
        PrintTable (player.GetAll ())
    else
        local ply = VipdGetPlayer(arguments[1])
        if ply then
            local vply = GetVply(ply:Name())
            if vply.LastPosition then
                ply:SetPos(vply.LastPosition)
                vply.LastPosition = nil
            else
                VipdLog (vINFO, "No saved position for "..ply:Name())
            end
        else
            VipdLog (vWARN, "Unable to find player: "..arguments[1])
        end
    end
end

local function VipdPlayerPosUpdate( ply, attacker, dmg )
    local vply = GetVply(ply:Name())
    if vply.PreviousPos2 then
        vply.LastPosition = vply.PreviousPos2
        VipdLog(vDEBUG, ply:Name().." died or disconnected, saved last position as: "..tostring(vply.LastPosition))
    else
        VipdLog(vDEBUG, ply:Name().." died or disconnected, unable to save last position!")
    end
end

hook.Add( "OnNPCKilled", "VipdNPCKilled", VipdNpcKilled)
hook.Add( "DoPlayerDeath", "VipdPlayerDeathPosUpdate", VipdPlayerPosUpdate )
hook.Add( "PlayerDisconnected", "VipdPlayerDisconnectPosUpdate", VipdPlayerPosUpdate )
