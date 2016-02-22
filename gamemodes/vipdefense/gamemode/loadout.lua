function GM:PlayerLoadout(ply)
    -- This is on a timer to override any map specific loadouts
    local level = GetLevel(ply)
    local grade = GetGrade(ply)
    timer.Simple(2, function()
        if IsValid (ply) then
            ply:SetTeam (1)
            ply:SetNoCollideWithTeammates (true)
            ply:StripWeapons()
            ply:Give("weapon_crowbar")
            ply:Give ("weapon_physcannon")
            if level > 1 then GivePlayerWeapon (ply, level, grade) end
        end
    end )
    return true
end