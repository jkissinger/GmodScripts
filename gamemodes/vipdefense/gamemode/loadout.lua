function GM:PlayerSpawn( ply )
	print( ply:Name() .. " has spawned!" )
	self.BaseClass:PlayerSpawn( ply )
end

function GM:PlayerLoadout(ply)
	print( ply:Name() .. " has loadout!" )
	print("ply: " .. ply:Name() .. " loadout in server")
	ply:StripWeapons()
    ply:Give("weapon_crowbar")
    ply:Give("weapon_physcannon")
    if GetLevel(ply) > 0 then
        for i = 0, GetGrade(ply), 1 do
            GivePlayerWeapon(ply)
        end
    end
	-- timer.Simple( 3, function()
		-- print("ply: " .. ply:Name() .. " loadout in server")
		-- ply:StripWeapons()
		-- ply:Give("weapon_crowbar")
		-- ply:Give("weapon_physcannon")
		-- if GetLevel(ply) > 0 then
			-- for i = 0, GetGrade(ply), 1 do
				-- GivePlayerWeapon(ply)
			-- end
		-- end
	-- end	)
    -- return true
end