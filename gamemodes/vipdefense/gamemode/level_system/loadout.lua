function GM:PlayerLoadout(ply)
    if not LevelSystem then return end
    -- This is on a timer to override any map specific loadouts
    timer.Simple(2, function() VipdLoadout(ply) end)
    return true
end

function VipdLoadout(ply)
    if IsValid (ply) then
        local level = GetLevel(ply)
        local grade = GetGrade(ply)
        ply:SetCustomCollisionCheck(true)
        ply:StripWeapons()
        --Give all tier 0 items always
        for classname, vipd_weapon in pairs(vipd_weapons) do
            if vipd_weapon.init then
                GiveWeaponAndAmmo(ply, classname, 3)
            end
        end
        local vply = GetVply(ply:Name())
        vDEBUG(vply.weapons)
        for class, count in pairs(vply.weapons) do
            for i=1, count do
                GiveWeaponAndAmmo(ply, class, 3)
            end
        end
    end
    VipdHudInit(vipd_weapons)
end
