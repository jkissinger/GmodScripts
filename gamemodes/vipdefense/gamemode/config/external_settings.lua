WeaponSettingsFile = "vipdefense\\weapon_settings.dat"
NpcSettingsFile = "vipdefense\\npc_settings.dat"

local function PersistWeapons()
    vDEBUG("Writing weapon settings to disk.")
    file.Write( WeaponSettingsFile, "Class, Name, NPC Value, Player Cost, Override, Initialized, Consumable, Minimum Cost, Maximum Cost\n" )
    for class, weapon in pairs(vipd_weapons) do
        local line = weapon.class .. "," .. weapon.name .. "," .. weapon.npcValue .. "," .. weapon.cost .. "," .. tostring(weapon.override)
        line = line .. "," .. tostring(weapon.init) .. "," .. tostring(weapon.consumable) .. "," .. tostring(weapon.mincost) .. "," .. tostring(weapon.maxcost)
        line = line .. "\n"
        file.Append(WeaponSettingsFile, line)
    end
end

local function PersistNpcs()
    vDEBUG("Writing NPC settings to disk.")
    file.Write( NpcSettingsFile, "Class, Name\n" )
    for class, npc in pairs(vipd_npcs) do
        local line = npc.class .. "," .. npc.name
        line = line .. "\n"
        file.Append(NpcSettingsFile, line)
    end
end

local function toNumberSafe(number)
    if tostring(number) == "nil" then number = 0 end
    return tonumber(number)
end

function PersistSettings()
    PersistNpcs()
    PersistWeapons()
end

function AddWeapon(class, name, npc_value, cost, override, init, consumable, mincost, maxcost)
    if not vipd_weapons[class] then vipd_weapons[class] = { class = class } end
    local weapon = vipd_weapons[class]
    weapon.name = name
    weapon.npcValue = toNumberSafe(npc_value)
    weapon.cost = toNumberSafe(cost)
    weapon.override = override == "true"
    weapon.init = init == "true"
    weapon.consumable = consumable == "true"
    weapon.mincost = toNumberSafe(mincost)
    weapon.maxcost = toNumberSafe(maxcost)
    vDEBUG("Loaded weapon: Class=" .. class .. " Name=" .. name .. "NPC Value=" .. npc_value .. " Cost=" .. cost)
end

function ReadWeaponsFromDisk()
    vDEBUG("Reading settings from disk.")
    local settings = file.Read(WeaponSettingsFile, "DATA")
    if not settings then return end
    local lines = string.Split( settings, "\n" )
    -- Remove header line
    table.remove(lines, 1)
    for k, line in pairs(lines) do
        local props = string.Split( line, "," )
        local r_class = props[1]
        local r_name = props[2]
        local r_npc_value = props[3]
        local r_cost = props[4]
        local r_override = props[5]
        local r_init = props[6]
        local r_consumable = props[7]
        local r_mincost = props[8]
        local r_maxcost = props[9]
        if r_class and r_name and r_npc_value and r_cost then
            AddWeapon(r_class, r_name, r_npc_value, r_cost, r_override, r_init, r_consumable, r_mincost, r_maxcost)
        end
    end
end
