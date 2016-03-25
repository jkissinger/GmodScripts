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
                data.className = class
                GiveWeaponAndAmmo(ply, data, 3)
            end
        end
        for i = 1, grade, 1 do
            GiveWeaponAndAmmo(ply, GetWeaponForTier(ply, i), 3)
        end
    end
end
