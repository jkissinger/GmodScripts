-- Number of kills per level
LevelInterval = 4
-- Number of levels between grades
GradeInterval = 3

function StartCoop()
    print("Started coop mode")
    RunConsoleCommand("sbox_noclip", "0")
    RunConsoleCommand("sbox_godmode", "0")
    RunConsoleCommand("sbox_playershurtplayers", "0")
    RunConsoleCommand("sbox_weapons", "0")
    SpawnPlayers()
    CheckLoadouts()
end

function SpawnPlayers()
    for k, ply in pairs(player.GetAll()) do
        ply:StripWeapons()
    end
end

--Track kills
hook.Add("OnNPCKilled", "NPC Killed", NpcKilled)

function NpcKilled(victim, attacker, inflictor)
    if IsValid(attacker) and attacker:IsPlayer() then
        attacker:AddFrags(1)
        if (attacker:Frags() % LevelInterval == 0) then
            level = GetLevel(attacker)
            MsgPlayer(attacker, "You leveled up! You are now level " .. level)
            GivePlayerWeapon(attacker)
        else
            MsgPlayer(attacker, "You earned a credit! " .. KillsToNextLevel(attacker) .. " more until level " ..(GetLevel(attacker) + 1))
        end
    end
end

function GivePlayerWeapon(ply, level)
    grade = GetGrade(ply)
    tier = GetTier() + grade
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
    elseif tier >= 8 then
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
    MsgPlayer(ply, "You were given a special bonus! An "..special)
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
    numClips =(GetLevel(ply) % GradeInterval) + 1
    if not ply:HasWeapon(weaponName) then
        weapon = ply:Give(weaponName)
    else
        weapon = ply:GetWeapon(weaponName)
        -- Player already has the weapon, give them an extra clip
        numClips = numClips + 1
    end
    ammoType = weapon:GetPrimaryAmmoType()
    clipSize = weapon:GetMaxClip1()
    ammoQuantity = clipSize * numClips
    ply:GiveAmmo(ammoQuantity, ammoType, false)
    MsgPlayer(ply, "You earned a " .. weaponName .. " and " .. numClips .. " clips")
    if GetLevel(ply) % GradeInterval == 0 then
		MsgPlayer(ply, "Your skill with weapons increased to Grade "..GetGrade(ply))
        for i = 0, GetGrade(ply), 1 do
            GiveGradeBonus(ply)
        end
    end
end

function GiveGradeBonus(ply)
    -- item_healthkit
    -- item_battery
    -- item_healthvial
    -- npc_alyx
    ply:Give("item_battery")
end

function GetGrade(ply)
    return math.floor(GetLevel(ply) / GradeInterval)
end

function GetLevel(ply)
    return math.floor(ply:Frags() / LevelInterval)
end

function KillsToNextLevel(ply)
    return LevelInterval - ply:Frags() % LevelInterval
end

function LevelsToNextGrade(ply)
    return GradeInterval - GetLevel(ply) % GradeInterval
end

function MsgPlayer(ply, msg)
    ply:PrintMessage(HUD_PRINTTALK, msg)
end


-- Set the player's loadout
hook.Add("PlayerLoadout", "player spawned remove weapons", CoopLoadout)

function CheckLoadouts()
    for k, ply in pairs(player.GetAll()) do
        CheckLoadout(ply, 0)
    end
end

function CheckLoadout(ply, mv)
    weapon = ply:GetActiveWeapon()
    if not IsValid(weapon) then
        DoLoadout(ply)
    elseif weapon:GetClass() == "weapon_physgun" then
        ply:StripWeapons()
        DoLoadout(ply)
    end
end

local function CoopLoadout(ply)
    print("Player spawned, doing loadout!")
	--USE TIMER HERE TO DO THE LOADOUT 3 Seconds After Loadout! (or spawn)
    DoLoadout(ply)
    return false
end

function DoLoadout(ply)
    print("ply: " .. ply:GetName() .. " loadout")
    ply:StripWeapons()
    ply:Give("weapon_crowbar")
    ply:Give("weapon_physcannon")
    if GetLevel(ply) > 0 then
        for i = 0, GetGrade(ply), 1 do
            GivePlayerWeapon(ply)
        end
    end
end

StartCoop()