--TODO: Add weapon selling
--TODO: Add ammo purchasing

local function ValidateArguments(ply, arguments)
    if not arguments[1] or not arguments[2] then
        Notify(ply, "Invalid arguments, unable to buy weapon.")
    else
        local permanence = arguments[1]
        local vipd_weapon = vipd_weapons[arguments[2]]
        if(permanence ~= TEMP and permanence ~= PERM) then
            Notify(ply, "Invalid arguments, permanence must be '"..TEMP.."' or '"..PERM.."'.")
            return false
        elseif(not vipd_weapon) then
            Notify(ply, "Unknown weapon '"..tostring(vipd_weapon).."'.")
            return false
        elseif(not vipd_weapon.cost) then
            Notify(ply, "Cannot buy "..tostring(vipd_weapon.name)..", it has no cost specified.")
            return false
        end
        local points = GetAvailablePoints(ply)
        local cost_modifier = 1
        if permanence == PERM then cost_modifier = PERM_MODIFIER end
        local weapon_cost = vipd_weapon.cost * cost_modifier
        if points < weapon_cost then
            Notify(ply, "Cannot buy "..tostring(vipd_weapon.name)..", you don't have "..weapon_cost.." points.")
            return false
        end
        local vply = GetVply(ply:Name())
        if not vply.weapons[vipd_weapon.class] then vply.weapons[vipd_weapon.class] = 0 end
        local can_be_permanent = vply.weapons[vipd_weapon.class] < vipd_weapon.max_permanent and vipd_weapon.max_permanent > 0
        if permanence == PERM and not can_be_permanent then
            Notify(ply, "Cannot permanently buy any more "..vipd_weapon.name)
            return false
        end

        return permanence, vipd_weapon
    end
end

function BuyWeapon(ply, cmd, arguments)
    local permanence, vipd_weapon = ValidateArguments(ply, arguments)
    if permanence and vipd_weapon then
        GiveWeaponAndAmmo(ply, vipd_weapon.class, 3)
        if(permanence == PERM) then
            local vply = GetVply(ply:Name())
            vply.weapons[vipd_weapon.class] = vply.weapons[vipd_weapon.class] + 1
            UsePoints(ply, vipd_weapon.cost * PERM_MODIFIER)
            vipd_weapon.perm_buys = vipd_weapon.perm_buys + 1
        else
            UsePoints(ply, vipd_weapon.cost)
            vipd_weapon.temp_buys = vipd_weapon.temp_buys + 1
        end
    end
end

function AdjustWeaponCosts()
    for class, weapon in pairs(vipd_weapons) do
        local weapon_adjust_percent = TEMP_BUY_ADJUST_PERCENT * weapon.temp_buys + PERM_BUY_ADJUST_PERCENT * weapon.perm_buys
        if weapon_adjust_percent == 0 then weapon_adjust_percent = NO_BUY_ADJUST_PERCENT end
        local adjustment = math.ceil(weapon_adjust_percent * weapon.cost / 100)
        if adjustment == 0 and weapon_adjust_percent > 0 then adjustment = 1 end
        if adjustment == 0 and weapon_adjust_percent < 0 then adjustment = -1 end
        local adjusted_cost = weapon.cost + adjustment
        if adjusted_cost == 0 and weapon.cost > 0 then adjusted_cost = 1 end
        if weapon.cost > 0 and not weapon.consumable then
            vDEBUG("Adjusted " .. weapon.name .. " from " .. weapon.cost .. " to " .. adjusted_cost)
            weapon.cost = adjusted_cost
        end
        weapon.temp_buys = 0
        weapon.perm_buys = 0
    end
end
