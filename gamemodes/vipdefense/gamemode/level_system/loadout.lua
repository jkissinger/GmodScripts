function GM:PlayerLoadout(ply)
    if not LevelSystem then return end
    if VIPD_LOADOUT_OVERRIDE then
        -- This is on a timer to override any map specific loadouts
        timer.Simple(2, function() VipdLoadout(ply) end)
    else
        VipdLoadout(ply)
    end
    return true
end

function VipdLoadout(ply)
    if IsValid(ply) then
        local level = GetLevel(ply)
        local grade = GetGrade(ply)
        ply:SetCustomCollisionCheck(true)
        if VIPD_LOADOUT_OVERRIDE then ply:StripWeapons() end
        --Give all 'init' weapons
        for classname, vipd_weapon in pairs(vipd_weapons) do
            if vipd_weapon.init then
                GiveWeaponAndAmmo(ply, classname, 3)
            end
        end
        local vply = GetVply(ply:Name())
        for class, count in pairs(vply.weapons) do
            for i=1, count do
                local num_clips = math.floor(level/3)+1
                GiveWeaponAndAmmo(ply, class, num_clips)
            end
        end
        --TODO: Move this to somewhere more reasonable, such as client being loaded
        VipdHudInit(vipd_weapons)
    end
end
