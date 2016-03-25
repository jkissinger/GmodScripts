local function GetNpcPointValue(npcEnt)
    local className = npcEnt:GetClass()
    local skill = npcEnt:GetCurrentWeaponProficiency() * 2
    local weapon = npcEnt:GetActiveWeapon()
    local weaponClass = "none"
    local weaponValue = 0
    if weapon and IsValid(weapon) then
        weaponClass = weapon:GetClass()
    end
    local points = GetPointValue(weaponClass, skill, className)
    VipdLog(vTRACE, "NPC className: " .. className .. " worth " .. points .. " skill " .. skill)
    return points
end

local function LevelSystemKillConfirm(victim, ply, inflictor)
    if IsValid(ply) and ply:IsPlayer() then
        local pointsEarned = GetNpcPointValue(victim)
        if pointsEarned < 0 then BroadcastError(victim:GetClass() .. " has no points defined!") end
        if pointsEarned >= 1 then
            AddPoints(ply, pointsEarned)
        end
    end
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

local function HasWeapon(ply, weaponClass)
    return IsValid( ply:GetWeapon( weaponClass ) )
end

local function GivePlayerTierWeapon(ply, level, grade)
    local tier = grade
    if tier == 0 then VipdLog(vWARN, "Call for tier 0 weapon") end
    local newWeapon = GetWeaponForTier(ply, tier)
    if tier > MaxTier then
        GiveBonuses(ply, GetGrade(ply) - MaxTier)
    end
    GiveWeaponAndAmmo(ply, newWeapon, 3)
end

local function GivePlayerAmmoForWeapon(ply, weaponEnt)
    if weaponEnt.GetPrimaryAmmoType ~= nil then
        local ammoType = weaponEnt:GetPrimaryAmmoType()
        local clipSize = weaponEnt:GetMaxClip1()
        if clipSize < 1 then clipSize = 1 end
        local clips = math.random(1, 3)
        local ammoQuantity = clipSize * clips
        if string.lower(ammoType) ~= "none" then
            ply:GiveAmmo(ammoQuantity, ammoType, false)
        end
    else
        VipdLog(vDEBUG, weaponEnt:GetClass().." had no primary ammo function")
    end
end

local function GivePlayerAmmo(ply)
    for k, weaponEnt in pairs(ply:GetWeapons()) do
        GivePlayerAmmoForWeapon(ply, weaponEnt)
    end
end

function AddPoints(ply, points)
    local currLevel = GetLevel(ply)
    local currGrade = GetGrade(ply)
    SetPoints(ply, GetActualPoints(ply) + points)
    local newLevel = GetLevel(ply)
    local newGrade = GetGrade(ply)

    for level = currLevel+1, newLevel do
        Notify(ply, "You leveled up! You are now level " .. level)
        GivePlayerAmmo(ply)
    end

    if newGrade > currGrade and GetPoints(ply) > 0 then
        for grade = currGrade+1, newGrade do
            GivePlayerTierWeapon(ply, newLevel, grade)
            Notify(ply, "Your skill with weapons increased to Grade " .. grade)
        end
    end

    ply:SetFrags(newLevel)
end

function GetWeaponForTier(ply, tier)
    if tier > MaxTier then tier = MaxTier end
    local weapons = { }
    for className, weapon in pairs(vipd_weapons) do
        if weapon.tier == tier then
            VipdLog(vTRACE, "Tier = " .. tier.." Weapon tier: "..weapon.tier)
            weapon.className = className
            table.insert(weapons, weapon)
        end
    end
    --Get a new weapon for the tier if possible
    for k, weapon in pairs(weapons) do
        if HasWeapon(ply, weapon.className) and #weapons > 1 then
            table.remove(weapons, weaopn)
        end
    end
    return weapons[math.random(#weapons)]
end

local function GetSpecial()
    --TODO: Iterate over possible secondary ammo, add to table along with rpg rounds, randomly choose from table
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

local function GiveBonus(plyData)
    local bonus = "item_battery"
    if plyData.Health < 100 then
        bonus = "item_healthkit"
        plyData.Health = plyData.Health + 25
    elseif plyData.Armor < 100 then
        bonus = "item_battery"
        plyData.Armor = plyData.Armor + 25
    elseif plyData.Grade > MaxTier then
        bonus = GetSpecial()
        -- spawn npc ally?
    end
    return bonus
end

function GiveWeaponAndAmmo(ply, weapon, clips)
    local weaponEnt = nil
    if not HasWeapon(ply, weapon.className) then
        weaponEnt = ply:Give(weapon.className)
        VipdLog(vDEBUG, "Giving "..ply:Name().." a "..weapon.className)
    else
        weaponEnt = ply:GetWeapon(weapon.className)
        clips = clips + 1
    end
    if weaponEnt == nil or not weaponEnt:IsValid() then
        VipdLog(vDEBUG, "Weapon is nil: " ..weapon.className)
    else
        GivePlayerAmmoForWeapon(ply, weaponEnt)
    end
end

function GiveBonuses(ply, num)
    local plyData = { }
    plyData.Health = ply:Health()
    plyData.Armor = ply:Armor()
    plyData.Grade = GetGrade(ply)
    for i = 1, num do
        local bonus = GiveBonus(plyData)
        VipdLog(vDEBUG, "Giving bonus of "..bonus.." to " .. ply:Name() .. " temphealth: " .. plyData.Health .. " temparmor: " .. plyData.Armor)
        ply:Give(bonus)
    end
end

function GetPointValue(WeaponClass, Skill, EntClass)
    local npc = vipd_npcs[EntClass]
    if npc == nil then return -1 end
    if vipd_weapons[WeaponClass] then
        return npc.value + vipd_weapons[WeaponClass].npcValue
    else
        VipdLog(vTRACE, EntClass.." had an undefined weapon: "..WeaponClass)
        return npc.value
    end
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

--===============

--=============

function GM:ShouldCollide( ent1, ent2 )
    return not (ent1:IsPlayer() and ent2:IsPlayer())
end

hook.Add( "OnNPCKilled", "VipdLevelNPCKilled", LevelSystemKillConfirm)
hook.Add( "DoPlayerDeath", "VipdPlayerDeathPosUpdate", VipdPlayerPosUpdate )
hook.Add( "PlayerDisconnected", "VipdPlayerDisconnectPosUpdate", VipdPlayerPosUpdate )
