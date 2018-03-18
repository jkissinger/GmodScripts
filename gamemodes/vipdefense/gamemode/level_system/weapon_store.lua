--TODO: Add weapon selling
--TODO: Add ammo purchasing

local function ValidateArguments(ply, arguments)
    if not arguments[1] or not arguments[2] then
        Notify(ply, "Invalid arguments, unable to buy weapon.")
    else
        local permanence = arguments[1]
        local vipd_weapon = vipd_weapons[arguments[2]]
        if (permanence ~= TEMP and permanence ~= PERM) then
            Notify(ply, "Invalid arguments, permanence must be '" .. TEMP .. "' or '" .. PERM .. "'.")
            return false
        elseif (not vipd_weapon) then
            Notify(ply, "Unknown weapon '" .. tostring(vipd_weapon) .. "'.")
            return false
        elseif (not vipd_weapon.cost) then
            Notify(ply, "Cannot buy " .. tostring(vipd_weapon.name) .. ", it has no cost specified.")
            return false
        end
        local points = GetAvailablePoints(ply)
        local cost_modifier = 1
        if permanence == PERM then
            cost_modifier = PERM_MODIFIER
        end
        local weapon_cost = vipd_weapon.cost * cost_modifier
        if points < weapon_cost then
            Notify(ply, "Cannot buy " .. tostring(vipd_weapon.name) .. ", you don't have " .. weapon_cost .. " points.")
            return false
        end
        local vply = GetVply(ply:Name())
        if not vply.weapons[vipd_weapon.class] then
            vply.weapons[vipd_weapon.class] = 0
        end
        local can_be_permanent = vply.weapons[vipd_weapon.class] < vipd_weapon.max_permanent and vipd_weapon.max_permanent > 0
        if permanence == PERM and not can_be_permanent then
            Notify(ply, "Cannot permanently buy any more " .. vipd_weapon.name)
            return false
        end

        return permanence, vipd_weapon
    end
end

local function AdjustWeaponCost(weapon, total_points_spent)
    -- A weapons cost is it's percentage of total points spent times the global max
    local percentage_of_purchases = weapon.points_spent / total_points_spent
    if weapon.maxcost == 0 then
        weapon.maxcost = GLOBAL_MAX_COST
    end
    local adjusted_cost = math.floor(percentage_of_purchases * weapon.maxcost)
    if weapon.mincost == 0 then
        weapon.mincost = GLOBAL_MIN_COST
    end
    if weapon.points_spent == 0 then
        adjusted_cost = weapon.mincost
    end
    local below_max = adjusted_cost <= weapon.maxcost
    local above_min = adjusted_cost >= weapon.mincost
    if weapon.cost > 0 and not weapon.consumable and below_max and above_min and weapon.cost ~= adjusted_cost then
        vDEBUG("Adjusted " .. weapon.name .. " from " .. weapon.cost .. " to " .. adjusted_cost .. " points spent: " .. weapon.points_spent .. " percent: " .. percentage_of_purchases .. " maxcost: " .. weapon.maxcost)
        weapon.cost = adjusted_cost
    end
end

function BuyWeapon(ply, cmd, arguments)
    local permanence, vipd_weapon = ValidateArguments(ply, arguments)
    if permanence and vipd_weapon then
        GiveWeaponAndAmmo(ply, vipd_weapon.class, 3)
        local points_spent = vipd_weapon.cost
        if (permanence == PERM) then
            local vply = GetVply(ply:Name())
            vply.weapons[vipd_weapon.class] = vply.weapons[vipd_weapon.class] + 1
            points_spent = vipd_weapon.cost * PERM_PURCHASE_FACTOR
        end
        UsePoints(ply, points_spent)
        vipd_weapon.points_spent = vipd_weapon.points_spent + points_spent
        AdjustWeaponCosts()
        PersistSettings()
    end
end

function AdjustWeaponCosts()
    vDEBUG("Adjusting weapon costs")
    local total_points_spent = 0
    for class, weapon in pairs(vipd_weapons) do
        if weapon.enabled then
            total_points_spent = total_points_spent + weapon.points_spent
        end
    end
    vDEBUG("Total points spent: " .. total_points_spent)
    for class, weapon in pairs(vipd_weapons) do
        AdjustWeaponCost(weapon, total_points_spent)
    end
    VipdUpdateClientStore()
end