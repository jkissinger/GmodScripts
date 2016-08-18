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
    local chance = math.random(1, 3)
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

local function ValidateArguments(ply, arguments, admin_required)
    if IsValid(ply) and admin_required and not ply:IsAdmin() then
        Notify(ply, "That command is only for admins")
        return false
    end
    if not arguments [1] or not arguments [2] then
        local t = { }
        for k, player in pairs(player.GetAll()) do
            local p = { }
            p.ply = player
            local vply = GetVply(player:Name())
            p.actualPoints = GetActualPoints(player)
            p.handicap = vply.handicap
            p.points = GetPoints(player)
            if IsValid(ply) then
                MsgPlayer(ply, tostring(player))
                MsgPlayer(ply, "actual points = "..p.actualPoints)
                MsgPlayer(ply, "handicap = "..p.handicap)
                MsgPlayer(ply, "adjusted points = "..p.points)
            end
            table.insert(t, p)
        end
        PrintTable(t)
        return false
    else
        return true
    end
end

function SetHandicap(ply, cmd, arguments)
    if ValidateArguments(ply, arguments, true) then
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

function GivePoints(ply, cmd, arguments)
    if ValidateArguments(ply, arguments, true) then
        local plyTo = VipdGetPlayer(arguments[1])
        local num_points = tonumber(arguments[2])
        if not plyTo then
            vWARN("Unable to find player: "..arguments[1])
        elseif num_points == nil then
            Notify(ply, arguments[2].." is not a number!")
        else
            AddPoints(plyTo, num_points)
        end
    end
end

function GetNameFromClass(classname)
    local vipd_npc = vipd_npcs[classname]
    local name = "Unknown"
    if not vipd_npc then
        name = "a " .. ent.team.name
    else
        name = vipd_npc.name
    end
    return name
end

function MapEnd()
    AdjustWeaponCosts()
    PersistSettings()
end

--==================--
--Teleport Functions--
--==================--

function TeleportAll(ply, cmd, arguments)
    if IsValid(ply) and admin_required and not ply:IsAdmin() then
        Notify(ply, "That command is only for admins")
        return false
    end
    for k, player in pairs(player.GetAll()) do
        vINFO("Teleporting " .. player:Name() .. " to " .. ply:Name())
        player:SetPos(ply:GetPos())
    end
end

function TeleportToLastPos(ply, cmd, arguments)
    if ply then
        local vply = GetVply(ply:Name())
        if vply.LastPosition then
            ply:SetPos(vply.LastPosition)
            vply.LastPosition = nil
        else
            Notify(ply, "You have no saved position!")
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

--================
--=Initialization=
--================

local function GetDataFromGmod(vipd_weapon)
    local class = vipd_weapon.class
    local swep = weapons.Get( class )
    if swep == nil then
        swep = list.Get("Weapon")[class]
    end
    if swep == nil then
        swep = list.Get("SpawnableEntities")[name]
    end
    if swep ~= nil then
        vipd_weapon.name = swep.PrintName
        if swep.Primary then vipd_weapon.primary_ammo = swep.Primary.Ammo end
        if swep.Secondary then vipd_weapon.secondary_ammo = swep.Secondary.Ammo end
    end
    if not vipd_weapon.name then vipd_weapon.name = class end
    if not vipd_weapon.override then vipd_weapon.override = false end
end

function InitializeLevelSystem()
    vINFO("Initializing Level System")
    ReadWeaponsFromDisk()
    for class, vipd_weapon in pairs(vipd_weapons) do
        RegisteredWeaponCount = RegisteredWeaponCount + 1
        if not vipd_weapon.cost then vipd_weapon.cost = 0 end
        if not vipd_weapon.npcValue then vipd_weapon.npcValue = 0 end
        if not vipd_weapon.class then vipd_weapon.class = class end
        if not vipd_weapon.max_permanent then vipd_weapon.max_permanent = 1 end
        if not vipd_weapon.temp_buys then vipd_weapon.temp_buys = 0 end
        if not vipd_weapon.perm_buys then vipd_weapon.perm_buys = 0 end
        if not vipd_weapon.init then vipd_weapon.init = false end
        if not vipd_weapon.consumable then vipd_weapon.consumable = false end
        GetDataFromGmod(vipd_weapon)
    end
    for key, vipd_npc in pairs(vipd_npcs) do
        RegisteredNpcCount = RegisteredNpcCount + 1
        vipd_npc.gmod_class = key
        vipd_npc.class = key
        local gmod_npc = list.Get("NPC")[key]
        if gmod_npc then
            if gmod_npc.Class then vipd_npc.class = gmod_npc.Class end
            if gmod_npc.Name then vipd_npc.name = gmod_npc.Name end
            if gmod_npc.Model then
                NpcsByModel[gmod_npc.Model] = { name = vipd_npc.name, value = vipd_npc.value }
                vDEBUG("Associated "..vipd_npc.name.." with model "..gmod_npc.Model)
            end
        end
    end
    ValidateWeapons()
    ValidateNpcs()
    PersistSettings()
end

--=======
--=Hooks=
--=======

function GM:ShouldCollide( ent1, ent2 )
    return PVP_ENABLED:GetBool() or not (ent1:IsPlayer() and ent2:IsPlayer())
end

hook.Add( "DoPlayerDeath", "VipdPlayerDeathPosUpdate", VipdPlayerPosUpdate )
hook.Add( "PlayerDisconnected", "VipdPlayerDisconnectPosUpdate", VipdPlayerPosUpdate )
