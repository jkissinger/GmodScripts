AddCSLuaFile()

function StartCoop()
    print("Started coop mode")
    RunConsoleCommand("sbox_noclip", "0")
    RunConsoleCommand("sbox_godmode", "0")
    RunConsoleCommand("sbox_playershurtplayers", "0")
    CheckLoadouts()
end

--Track player kills and award weapons every killAwardInterval kills
killAwardInterval = 5

hook.Add( "OnNPCKilled", "NPC Killed", NpcKilled )

function NpcKilled(victim, attacker, inflictor)
	if IsValid(attacker) and attacker:IsPlayer() then
		attacker:AddFrags(1)
		if (attacker:Frags() % killAwardInterval == 0) then
			attacker:PrintMessage(HUD_PRINTTALK, "You killed: "..victim:GetClass())
            level = attacker:Frags() / killAwardInterval
            attacker:PrintMessage(HUD_PRINTTALK, "You leveled up! You are now level "..level)
			GivePlayerWeapon(attacker, level)
		else
			local nextLevel = killAwardInterval - attacker:Frags() % killAwardInterval
			attacker:PrintMessage(HUD_PRINTTALK, "You killed: "..victim:GetClass().." "..nextLevel.." more until next level")
		end
    else
        print("NPC killed?")
	end
end

function GivePlayerWeapon(ply, level)
	weaponNum = math.random(1, 50) + level * 2
    ply:PrintMessage(HUD_PRINTTALK, "Debug: Weapon Num: "..weaponNum)
	print( "Debug: Giving weapon num: "..weaponNum )
	if weaponNum <= 20 then
		GiveWeaponAndAmmo(ply, "weapon_pistol", "item_ammo_pistol", level)
	elseif weaponNum >= 21 and weaponNum <= 30 then
		GiveWeaponAndAmmo(ply, "weapon_smg1", "item_ammo_smg1", level)
	elseif weaponNum >= 31 and weaponNum <= 41 then
		GiveWeaponAndAmmo(ply, "weapon_shotgun", "item_box_buckshot", level)
	elseif weaponNum == 42 then
		GiveWeaponAndAmmo(ply, "weapon_annabelle", "item_box_buckshot", level)
	elseif weaponNum == 43 and weaponNum <= 60 then
		GiveWeaponAndAmmo(ply, "weapon_357", "item_ammo_357", level)
	elseif weaponNum >= 61 and weaponNum <= 70 then
		GiveWeaponAndAmmo(ply, "weapon_ar2", "item_ammo_ar2", level)
	elseif weaponNum >= 71 and weaponNum <= 80 then
		GiveWeaponAndAmmo(ply, "weapon_crossbow", "item_ammo_crossbow", level)
	elseif weaponNum >= 81 and weaponNum <= 90 then
		GiveWeaponAndAmmo(ply, "item_ammo_ar2_altfire", "weapon_frag", level)
	elseif weaponNum >= 91 and weaponNum <= 100 then
		GiveWeaponAndAmmo(ply, "weapon_rpg", "item_rpg_round", level)
	elseif weaponNum > 100 then
		GiveWeaponAndAmmo(ply, "item_ammo_ar2_altfire", "item_ammo_smg1_grenade", level)
	end
end

function GiveWeaponAndAmmo(ply, weapon, secondary, level)
	ply:Give(weapon)
	for i=0,level,1 do
		ply:Give(secondary)
	end
    if level % 5 then
        ply:Give("item_healthkit")
    end
	ply:PrintMessage( HUD_PRINTTALK, "Congratulations you earned a bonus! "..weapon.." and "..level.." "..secondary )
end


--Control use of spawn menu
hook.Add( "SpawnMenuOpen", "AdminOnlySpawnMenu", DisallowSpawnMenu)

function DisallowSpawnMenu( )
	if not LocalPlayer():IsAdmin() then
        print("You are not an admin and may not use the spawn menu")
		return false
	end
    print("You are an admin and may use the spawn menu")
end

--Set the player's loadout
hook.Add( "PlayerLoadout", "player spawned remove weapons", CoopLoadout )

function CheckLoadouts()
    for k, v in pairs(player.GetAll()) do
        Msg( v:Nick() .. "\n")
        CheckLoadout(v)
    end
end

function CheckLoadout(ply, mv)
	weapon = ply:GetActiveWeapon()
	if not IsValid(weapon) then
		DoLoadout(ply)
	end
end

local function CoopLoadout(ply)
	DoLoadout(ply)
	return true
end

function DoLoadout(ply)
	print("ply: " .. ply:GetName() .. " loadout")
	ply:StripWeapons()
	ply:Give("weapon_crowbar")
	ply:Give("weapon_physcannon")
    level = math.ceil (ply:Frags() / killAwardInterval)
    if level > 0 then
        local grade = level / 5
        for i=0,grade,1 do
            GivePlayerWeapon(ply, level)
        end
    end
end

StartCoop()