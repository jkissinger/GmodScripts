local function InitializeGmodData()
    for key, weapon in pairs(list.Get("Weapon")) do
        local vipd_wep = vipd_weapons[key]
        if (weapon.Spawnable and vipd_wep == nil) then
            vINFO("Added spawnable weapon: " .. key)
            vipd_weapons[key] = { class = key }
        end
    end
    for key, npc in pairs(list.Get("NPC")) do
        local vipd_npc = vipd_npcs[key]
        if not vipd_npc then
            vipd_npcs[key] = { class = key }
            vDEBUG("Added spawnable NPC: " .. key .. " | " .. npc.Class)
        end
    end
end

function InitializeLevelSystem()
    vINFO("Initializing Level System")
    LoadPersistedData()
    InitializeGmodData()

    ValidateWeapons()
    ValidateNpcs()
    PersistSettings()
    AdjustWeaponCosts()
end