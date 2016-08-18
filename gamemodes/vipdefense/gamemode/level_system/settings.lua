function ValidateWeapons()
    for key, weapon in pairs(list.Get("Weapon")) do
        local vipd_wep = vipd_weapons[key]
        if(weapon.Spawnable and vipd_wep == nil) then
            vDEBUG("Spawnable weapon not in vipd_weapons: " .. key .. " adding it with default value: " .. DEFAULT_WEAPON_COST)
            vipd_weapons[key] = { class = key, name = weapon.PrintName, npcValue = 0, cost = DEFAULT_WEAPON_COST, override = false }
        end
    end
    for class, weapon in pairs(vipd_weapons) do
        local swep = weapons.Get( class )
        if swep == nil then
            swep = list.Get("Weapon")[class]
        end
        if swep == nil then
            swep = list.Get("SpawnableEntities")[class]
        end
        if swep == nil and class ~= "none" and not weapon.override then
            vDEBUG("Could not find "..class.." in gmod's list, removing it.")
            vipd_weapons[class] = nil
        end
    end
end

function ValidateNpcs()
    for key, npc in pairs(list.Get("NPC")) do
        local vipd_npc = vipd_npcs[key]
        if not vipd_npc then
            local class = npc.Class
            vDEBUG("Spawnable NPC not in vipd_npcs: " .. key .. " | " .. class)
        end
    end
    for class, npc in pairs(vipd_npcs) do
        local snpc = list.Get("NPC")[class]
        if snpc == nil and not npc.override then
            vDEBUG("Could not find "..class.." in gmod's list, removing it.")
            vipd_npcs[class] = nil
        end
    end
end
