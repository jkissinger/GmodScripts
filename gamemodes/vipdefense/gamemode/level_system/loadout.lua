function GM:PlayerLoadout(ply)
    if not LevelSystem then
        return
    end
    -- This is on a timer so the map can't override it
    timer.Simple(2, function()
        VipdLoadout(ply)
    end)
    return true
end

function VipdLoadout(ply, reset_weapons)
    if IsValid(ply) then
        local level = GetLevel(ply)
        local grade = GetGrade(ply)
        ply:SetCustomCollisionCheck(true)
        if VIPD_LOADOUT_OVERRIDE or reset_weapons then
            ply:StripWeapons()
        end
        --Give all 'init' weapons
        for classname, vipd_weapon in pairs(vipd_weapons) do
            if vipd_weapon.give_on_spawn and vipd_weapon.spawnable and vipd_weapon.enabled then
                GiveWeaponAndAmmo(ply, classname, 3)
            end
        end
        local vply = GetVply(ply:Name())
        for class, count in pairs(vply.weapons) do
            for i = 1, count do
                local num_clips = math.floor(level / 3) + 1
                GiveWeaponAndAmmo(ply, class, num_clips)
            end
        end
        VipdUpdateClientStore()
    end
end
