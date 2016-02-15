function GM:PlayerLoadout(ply)
    -- This is on a timer to override any map specific loadouts
    local level = GetLevel(ply)
    local grade = GetGrade(ply)
    timer.Simple(2, function()
        if IsValid(ply) then
            ply:StripWeapons()
            ply:Give("weapon_crowbar")
            ply:Give("weapon_physcannon")
            if level > 1 then
                for i = 0, grade, 1 do
                    GivePlayerWeapon(ply)
                end
            end
        end
    end )
    return true
end

function SetNoCollide (ply)
    ply:SetTeam (1)
    ply:SetNoCollideWithTeammates (true)
end

hook.Add ("PlayerInitialSpawn", "SetNoCollideForCoop", spawn)