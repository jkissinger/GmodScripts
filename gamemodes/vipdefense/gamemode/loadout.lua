function GM:PlayerLoadout(ply)
    --This is on a timer to override any map specific loadouts
	timer.Simple( 2, function()
		ply:StripWeapons()
		ply:Give("weapon_crowbar")
		ply:Give("weapon_physcannon")
		if GetLevel(ply) > 0 then
			for i = 0, GetGrade(ply), 1 do
				GivePlayerWeapon(ply)
			end
		end
	end	)
    return true
end