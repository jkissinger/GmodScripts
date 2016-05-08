local function ValidateArguments(ply, arguments)
    if not arguments[1] or not arguments[2] then
        Notify(ply, "Invalid arguments, unable to buy weapon.")
    else
        local permanence = arguments[1]
        local v_weapon = vipd_weapons[arguments[2]]
        v_weapon.className = arguments[2]
        if (permanence ~= TEMP and permanence ~= PERM) then
            Notify(ply, "Invalid arguments, permanence must be '"..TEMP.."' or '"..PERM.."'.")
            return false
        elseif (not v_weapon) then
            Notify(ply, "Unknown weapon '"..tostring(v_weapon).."'.")
            return false
        elseif (not v_weapon.cost) then
            Notify(ply, "Cannot buy "..tostring(v_weapon.name)..", it has no cost specified.")
            return false
        end
        local points = GetPoints(ply)
        if points < v_weapon.cost then
            Notify(ply, "Cannot buy "..tostring(v_weapon.name)..", you don't have enough money.")
            return false
        elseif permanence == PERM and points < v_weapon.cost * PERM_MODIFIER then
            Notify(ply, "Cannot buy permanent "..tostring(v_weapon.name)..", you don't have enough money.")
            return false
        end
        return permanence, v_weapon
    end
end

function BuyWeapon(ply, cmd, arguments)
    local permanence, v_weapon = ValidateArguments(ply, arguments)
    if (permanence ~= nil and v_weapon ~= nil) then
        GiveWeaponAndAmmo(ply, v_weapon.className, 3)
        if (permanence == PERM) then
            local vply = GetVply(ply:Name())
            vply.weapons[v_weapon.className] = true
            UsePoints(ply, v_weapon.cost * PERM_MODIFIER)
        else
            UsePoints(ply, v_weapon.cost)
        end
    else
        vINFO("Somehow they were null?")
    end
end

--TODO: Add ammo purchasing
