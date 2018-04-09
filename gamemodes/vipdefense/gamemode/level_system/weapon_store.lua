--TODO: Add weapon selling
--TODO: Add ammo purchasing
function IsWeaponPurchasable(vipd_weapon)
    return vipd_weapon.enabled and vipd_weapon.spawnable and not vipd_weapon.give_on_spawn
end

local function ValidateArguments(ply, arguments)
    if not arguments[1] or not arguments[2] then
        Notify(ply, "Invalid arguments, unable to buy weapon.")
    else
        local permanence = arguments[1]
        local vipd_weapon = vipd_weapons[arguments[2]]
        local mode = arguments[3] or PURCHASE_MODE_NORMAL
        if not vipd_weapon then
            Notify(ply, "Unknown weapon '" .. tostring(vipd_weapon) .. "'.")
            return false
        elseif not vipd_weapon.cost then
            Notify(ply, "Cannot buy " .. tostring(vipd_weapon.name) .. ", it has no cost specified.")
            return false
        end
        if permanence ~= PURCHASE_DURATION_TEMP and permanence ~= PURCHASE_DURATION_PERM then
            Notify(ply, "Invalid arguments, purchase duration must be '" .. PURCHASE_DURATION_TEMP .. "' or '" .. PURCHASE_DURATION_PERM .. "'.")
            return false
        end
        local points = GetAvailablePoints(ply)
        local cost_modifier = 1
        if permanence == PURCHASE_DURATION_PERM then
            cost_modifier = PERM_MODIFIER
        end
        local weapon_cost = vipd_weapon.cost * cost_modifier
        if points < weapon_cost and mode == PURCHASE_MODE_NORMAL then
            Notify(ply, "Cannot buy " .. tostring(vipd_weapon.name) .. ", you don't have " .. weapon_cost .. " points.")
            return false
        end
        local vply = GetVply(ply:Name())
        if not vply.weapons[vipd_weapon.class] then
            vply.weapons[vipd_weapon.class] = 0
        end
        local can_be_permanent = mode ~= PURCHASE_MODE_NORMAL or vply.weapons[vipd_weapon.class] < vipd_weapon.max_permanent and vipd_weapon.max_permanent > 0
        if permanence == PURCHASE_DURATION_PERM and not can_be_permanent then
            Notify(ply, "Cannot permanently buy any more " .. vipd_weapon.name)
            return false
        end

        return permanence, vipd_weapon, mode
    end
end

local function AdjustWeaponCost(weapon, total_points_spent, iteration)
    -- A weapons cost is it's percentage of total points spent times the global max
    local percentage_of_purchases = weapon.points_spent / total_points_spent
    if weapon.maxcost == 0 or weapon.maxcost > GLOBAL_MAX_COST then
        weapon.maxcost = GLOBAL_MAX_COST
    end
    local adjusted_cost = math.floor(percentage_of_purchases * weapon.maxcost)
    if weapon.mincost == 0 or weapon.mincost < GLOBAL_MIN_COST then
        weapon.mincost = GLOBAL_MIN_COST
    end
    local tier = math.floor(iteration / MAX_WEAPONS_PER_TIER)
    -- Grow exponentially and linearly
    local min_tier_cost = tier * tier * PERM_MODIFIER + tier * 10 + GLOBAL_MIN_COST
    if min_tier_cost > adjusted_cost then
        vDEBUG("Overriding cost with min_tier_cost for [" .. weapon.name .. "], tier=[" .. tier .. "], adjusted_cost=[" .. adjusted_cost .. "], min_tier_cost=[" .. min_tier_cost .. "].")
        adjusted_cost = min_tier_cost
    end
    if adjusted_cost < weapon.mincost then
        vDEBUG("Overriding cost with weapon.mincost for [" .. weapon.name .. "].")
        adjusted_cost = weapon.mincost
    end
    if adjusted_cost > weapon.maxcost then
        vDEBUG("Overriding cost with weapon.maxcost for [" .. weapon.name .. "].")
        adjusted_cost = weapon.maxcost
    end
    if weapon.cost > 0 and not weapon.consumable and weapon.cost ~= adjusted_cost then
        vDEBUG("Adjusted " .. weapon.name .. " from " .. weapon.cost .. " to " .. adjusted_cost .. " points spent: " .. weapon.points_spent .. " percent: " .. percentage_of_purchases .. " maxcost: " .. weapon.maxcost)
        weapon.cost = adjusted_cost
    end
end

function BuyWeapon(ply, cmd, arguments)
    local permanence, vipd_weapon, mode = ValidateArguments(ply, arguments)
    if permanence and vipd_weapon then
        if mode == PURCHASE_MODE_ADMIN_GIVE then
            for k, p in pairs(player.GetAll()) do
                GiveWeaponAndAmmo(p, vipd_weapon.class, 3)
                if permanence == PURCHASE_DURATION_PERM then
                    local vply = GetVply(p:Name())
                    if not vply.weapons[vipd_weapon.class] then
                        vply.weapons[vipd_weapon.class] = 0
                    end
                    vply.weapons[vipd_weapon.class] = vply.weapons[vipd_weapon.class] + 1
                end
            end
        else
            GiveWeaponAndAmmo(ply, vipd_weapon.class, 3)
            local points_spent = vipd_weapon.cost
            if permanence == PURCHASE_DURATION_PERM then
                local vply = GetVply(ply:Name())
                vply.weapons[vipd_weapon.class] = vply.weapons[vipd_weapon.class] + 1
                points_spent = vipd_weapon.cost * PERM_PURCHASE_FACTOR
            end
            -- Subtract points only for normal purchases
            if mode == PURCHASE_MODE_NORMAL then
                UsePoints(ply, points_spent)
                vipd_weapon.points_spent = vipd_weapon.points_spent + points_spent
                AdjustWeaponCosts()
            end
        end
    end
end

function AdjustWeaponCosts()
    vDEBUG("Adjusting weapon costs")
    local total_points_spent = 0
    for class, weapon in pairs(vipd_weapons) do
        if IsWeaponPurchasable(weapon) then
            total_points_spent = total_points_spent + weapon.points_spent
        end
    end
    vDEBUG("Total points spent: " .. total_points_spent)
    local iteration = 0
    -- This method "SortedPairsByMemberValue" creates a new value table for some reason
    local rank = { }
    for class, weapon in SortedPairsByMemberValue(vipd_weapons, "points_spent", false) do
        if IsWeaponPurchasable(weapon) then
            rank[weapon.name] = iteration
            iteration = iteration + 1
        end
    end
    for class, weapon in pairs(vipd_weapons) do
        if IsWeaponPurchasable(weapon) then
            AdjustWeaponCost(weapon, total_points_spent, rank[weapon.name])
        end
    end
    VipdUpdateClientStore()
    PersistSettings()
end