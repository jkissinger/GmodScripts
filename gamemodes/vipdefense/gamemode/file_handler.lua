if not file.Exists( "vipdefense", "DATA" ) then file.CreateDir("vipdefense") end
SettingsFile = "vipdefense\\settings.dat"
file.Write( SettingsFile, "Class, Name, NPC Value, Player Cost, Override\n" )

local function WriteWeaponToDisk(weapon)
    local line = weapon.class .. "," .. weapon.name .. "," .. weapon.npcValue .. "," .. weapon.cost .. "," .. tostring(weapon.override) .. "\n"
    file.Append(SettingsFile, line)
end

local function PrintWeapons()
    for key, weapon in pairs(list.Get("Weapon")) do
        local vipd_wep = vipd_weapons[key]
        if(weapon.Spawnable and vipd_wep == nil) then
            vDEBUG("Spawnable weapon not in vipd_weapons: " .. key)
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
        else
            WriteWeaponToDisk(weapon)
        end
    end
end

local function PrintNpcs()
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

function ValidateAndWriteNpcsAndWeapons()
    PrintNpcs()
    PrintWeapons()
end
