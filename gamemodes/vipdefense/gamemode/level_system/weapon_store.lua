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

local function AdjustWeaponCost(weapon)
    local no_buy_adjust_percent = StorePurchases
    if ADJUST_COSTS_IN_REALTIME then no_buy_adjust_percent = PRICE_REDUCTION end
    local temp_buy_adjust_percent = StoreInventoryCount
    local perm_buy_adjust_percent = temp_buy_adjust_percent * PERM_MODIFIER
    local weapon_adjust_percent = temp_buy_adjust_percent * weapon.temp_buys + perm_buy_adjust_percent * weapon.perm_buys
    --vDEBUG("No buy adjust percent: " .. no_buy_adjust_percent)
    --vDEBUG("Temp buy adjust percent: " .. temp_buy_adjust_percent)
    if weapon_adjust_percent == 0 then weapon_adjust_percent = no_buy_adjust_percent end
    local adjustment = math.ceil(weapon_adjust_percent * weapon.cost / 100)

    -- Adjust weapon cost by at least 1/-1
    if adjustment == 0 and weapon_adjust_percent > 0 then adjustment = 1 end
    if adjustment == 0 and weapon_adjust_percent < 0 then adjustment = -1 end

    local adjusted_cost = weapon.cost + adjustment
    if weapon.maxcost == 0 then weapon.maxcost = GLOBAL_MAX_COST end
    if weapon.mincost == 0 then weapon.mincost = GLOBAL_MIN_COST end
    local below_max = not weapon.maxcost or weapon.maxcost and adjusted_cost < weapon.maxcost
    local above_min = not weapon.mincost or weapon.mincost and adjusted_cost > weapon.mincost
    if weapon.cost > 0 and not weapon.consumable and below_max and above_min then
        vDEBUG("Adjusted " .. weapon.name .. " from " .. weapon.cost .. " to " .. adjusted_cost .. " temp: " .. weapon.temp_buys .. " perm: " .. weapon.perm_buys)
        weapon.cost = adjusted_cost
    end
    weapon.temp_buys = 0
    weapon.perm_buys = 0
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
        StorePurchases = StorePurchases + 1
        if ADJUST_COSTS_IN_REALTIME and StorePurchases >= PRICE_UPDATE_INCREMENT then
            AdjustWeaponCosts()
            PersistSettings()
        end
    end
end

function AdjustWeaponCosts()
    vINFO("Adjusting weapon costs")
    for class, weapon in pairs(vipd_weapons) do
        AdjustWeaponCost(weapon)
    end
    StorePurchases = 0
    VipdUpdateClientStore()
end

function NormalizeWeaponCostDistribution()
    vINFO("Normalizing weapon costs")
    local vipd_weapons_copy = {}

    for class, weapon in pairs(vipd_weapons) do
        if weapon.cost > 0 and not weapon.consumable then
            local weapon = { class=class, name=weapon.name, cost=weapon.cost}
            table.insert(vipd_weapons_copy, weapon)
        end
    end

    table.SortByMember(vipd_weapons_copy, "cost", true)
    local count = 0
    for class, weapon in ipairs(vipd_weapons_copy) do
        local weapon_count = #vipd_weapons_copy
        local normalized_cost = math.ceil(1-(1-count)^3/(weapon_count*2.5))
        count = count + 1
        local actual_weapon = vipd_weapons[weapon.class]
        if actual_weapon.mincost <= normalized_cost then
            vDEBUG("Weapon: " .. weapon.name .. " Cost: " .. tostring(weapon.cost) .. " Normalized to: " .. normalized_cost)
            actual_weapon.cost = normalized_cost
        else
            vDEBUG("Weapon: " .. weapon.name .. " not normalized, normalized cost would be lower than minimum cost.")
            actual_weapon.cost = actual_weapon.mincost
        end
    end
end
