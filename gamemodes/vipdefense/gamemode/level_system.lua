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
    VipdLog(vDEBUG, "NPC className: " .. className .. " worth " .. points .. " skill " .. skill)
    return points
end

function GM:OnNPCKilled(victim, ply, inflictor)
    -- TODO check if the npc killed itself, if so give credit to the last attacker/current enemy?
    if IsValid(ply) and ply:IsPlayer() then
        local pointsEarned = GetNpcPointValue(victim)
        if pointsEarned < 0 then Error(ply, victim:GetClass() .. " has no points defined!") end
        if pointsEarned < 1 then return end
        AddPoints(ply, pointsEarned)
    end
    if DefenseSystem and (victim.isEnemy or victim.isFriendly) then
        currentNpcs = currentNpcs - 1
        if victim.isEnemy then deadEnemies = deadEnemies + 1 end
        if victim.isFriendly then
            if IsValid(ply) and ply:IsPlayer() then
                Notify(ply, "You killed a "..VipdFriendlyTeam.."!")
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
        GiveBonus(ply)
    end

    ply:SetFrags(newLevel)
end

local function GetWeaponForTier(tier)
    if tier > MaxTier then tier = MaxTier end
    for className, weapon in pairs(vipd_weapons) do
        if weapon.value == tier then
            VipdLog(vTRACE, "Tier = " .. tier.." Weapon value: "..weapon.value)
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
    VipdLog(vDEBUG, "Tier = " .. tier)
    if tier > MaxTier then
        for i = MaxTier, GetGrade(ply), 1 do
            GiveBonus(ply)
        end
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

function GiveBonus(ply)
    local bonus = GetSpecial()
    if ply:Health() < 100 then
        bonus = "item_healthkit"
    elseif ply:Armor() < 100 then
        bonus = "item_battery"
    elseif GetGrade(ply) > MaxTier then
    -- spawn npc ally
    end
    VipdLog(vDEBUG, "Giving bonus of "..bonus.." to " .. ply:Name() .. " health: " .. ply:Health() .. " armor: " .. ply:Armor())
    ply:Give(bonus)
end

function GetPointValue(WeaponClass, Skill, EntClass)
    local npc = vipd_npcs[EntClass]
    if npc == nil then return -1 end
    return npc.value + vipd_weapons[WeaponClass].npcValue
end

-- Level system utils

function GetLevelInterval ()
    return GetConVarNumber ("vipd_pointsperlevel")
end

function GetGradeInterval ()
    return GetConVarNumber ("vipd_levelspergrade")
end

function GetActualPoints (ply)
    local vply = vipd.Players[ply:Name ()]
    if not vply then SetPoints (ply, 0) end
    local points = vipd.Players[ply:Name ()].points
    return points
end

function GetPoints (ply)
    local points = GetActualPoints (ply)
    local handicap = vipd.Players[ply:Name ()].handicap
    return points * handicap
end

function SetPoints (ply, points)
    local vply = vipd.Players[ply:Name ()]
    if not vply then
        vipd.Players[ply:Name ()] = { points = points, handicap = 1 }
    else
        vipd.Players[ply:Name()].points = points
    end
end

function GetGrade (ply)
    return GetGradeForLevel (GetLevel (ply))
end

function GetGradeForLevel (level)
    local grade = math.floor (level / GetGradeInterval ())
    if grade < 1 then grade = 1 end
    return grade
end

function GetLevel (ply)
    local plyPoints = GetPoints (ply)
    local plyLevel = 1
    if LevelTable then
        for level, levelPoints in pairs (LevelTable) do
            if plyPoints > levelPoints then
                plyLevel = level + 1
            else
                break
            end
        end
    end
    return plyLevel
end

function PointsToNextLevel (ply)
    local plyPoints = GetPoints (ply)
    local plyLevel = GetLevel (ply)
    local pointsToNextLevel = 0
    if LevelTable and plyLevel <= #LevelTable then
        pointsToNextLevel = LevelTable[plyLevel] - plyPoints
    end
    return pointsToNextLevel
end

function LevelsToNextGrade (ply)
    return GetGradeInterval () - GetLevel (ply) % GetGradeInterval ()
end

function SetHandicap(ply, cmd, arguments)
    if not arguments [1] or not arguments [2] then
        local t = { }
        for k, ply in pairs(player.GetAll()) do
            local p = { }
            p.ply = ply
            local vply = vipd.Players[ply:GetName()]
            if not vply then vipd.Players[ply:Name ()] = { points = 0, handicap = 1 } end
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
            local vply = vipd.Players[ply:GetName()]
            if not vply then
                vipd.Players[ply:Name ()] = { points = 0, handicap = handicap }
            else
                vply.handicap = handicap
            end
        end
    end
end
