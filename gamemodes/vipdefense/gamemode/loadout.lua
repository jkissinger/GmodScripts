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
        for class, data in pairs(vipd_weapons) do
            if data.tier == 0 then
                GiveWeaponAndAmmo(ply, class, 3)
            end
        end
        local vply = GetVply(ply:Name())
        vDEBUG(vply.weapons)
        for class, bool in pairs(vply.weapons) do
            GiveWeaponAndAmmo(ply, class, 3)
        end
    end
    VipdHudInit(vipd_weapons)
end
