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
        else
            UsePoints(ply, vipd_weapon.cost)
        end
    end
end
