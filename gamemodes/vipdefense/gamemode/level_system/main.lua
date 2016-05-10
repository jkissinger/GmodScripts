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

local function LevelSystemKillConfirm(victim, ply, inflictor)
    if IsValid(ply) and ply:IsPlayer() then
        local pointsEarned = GetNpcPointValue(victim)
        -- Could be false if npc class is undefined
        if pointsEarned then
            AddPoints(ply, pointsEarned)
            if pointsEarned < 0 then
                MsgCenter(ply:Name().. " killed a good guy!")
            end
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
        vDEBUG(weaponEnt:GetClass().." had no primary ammo function")
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
            Notify(ply, "Your skill with weapons increased to Grade " .. grade)
        end
    end

    ply:SetFrags(newLevel)
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

function GiveWeaponAndAmmo(ply, weaponClass, clips)
    local weaponEnt = nil
    if not HasWeapon(ply, weaponClass) then
        weaponEnt = ply:Give(weaponClass)
        vDEBUG("Giving "..ply:Name().." a "..weaponClass)
    else
        weaponEnt = ply:GetWeapon(weaponClass)
        clips = clips + 1
    end
    if weaponEnt == nil or not weaponEnt:IsValid() then
        vDEBUG("Weapon is nil: " ..weaponClass)
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
        vDEBUG("Giving bonus of "..bonus.." to " .. ply:Name() .. " temphealth: " .. plyData.Health .. " temparmor: " .. plyData.Armor)
        ply:Give(bonus)
    end
end

function GetPointValue(EntClass, Skill, WeaponClass)
    local npc = vipd_npcs[EntClass]
    local npc_value = 0
    if npc == nil then
        vWARN("NPC class: ".. EntClass .. " is not defined in the config!")
    else
        npc_value = npc.value
    end
    if vipd_weapons[WeaponClass] then
        local weapon_value = vipd_weapons[WeaponClass].npcValue
        if npc.value < 0 then
            return npc_value - weapon_value
        else
            return npc_value + weapon_value
        end
    else
        vDEBUG(EntClass.." had an undefined weapon: "..WeaponClass)
        return npc_value
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
            vWARN("Unable to find player: "..arguments[1])
        elseif not handicap then
            vWARN("Invalid handicap: "..arguments[2])
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
    if ply then
        local vply = GetVply(ply:Name())
        if vply.LastPosition then
            ply:SetPos(vply.LastPosition)
            vply.LastPosition = nil
        else
            Notify("You have no saved position!")
        end
    else
        vWARN("Unable to find player: "..arguments[1])
    end
end

local function VipdPlayerPosUpdate( ply, attacker, dmg )
    local vply = GetVply(ply:Name())
    if vply.PreviousPos2 then
        vply.LastPosition = vply.PreviousPos2
        vDEBUG(ply:Name().." died or disconnected, saved last position as: "..tostring(vply.LastPosition))
    else
        vDEBUG(ply:Name().." died or disconnected, unable to save last position!")
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
