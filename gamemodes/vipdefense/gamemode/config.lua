vipd_weapons = {
    -- Having weapons with the same value is fine, but players may never be given one of them
    -- There CANNOT be gaps, every value from 1 to the highest listed must be present
    ["weapon_crowbar"] = { name = "Crowbar", value = 0 },
    ["weapon_pistol"] = { name = "Pistol", value = 1 },
    ["weapon_shotgun"] = { name = "Shotgun", value = 2 },
    ["weapon_smg1"] = { name = "SMG", value = 3 },
    ["weapon_357"] = { name = "Magnum", value = 4 },
    ["weapon_ar2"] = { name = "AR2 Rifle", value = 5 },
    ["weapon_frag"] = { name = "Frag", value = 6 },
    ["weapon_crossbow"] = { name = "Crossbow", value = 7 },
    ["weapon_rpg"] = { name = "RPG", value = 8 }
}

vipd_npc_teams = {
    { name = "Zombies", minValue = 1},
    { name = "Combine", minValue = 1},
    { name = "Antlions", minValue = 3}
}

vipd_npcs = {
    -- NPCs that must be killed by RPG's cannot have a score less than 3 * RPG value + 4
    ["npc_headcrab"] = { name = "Headcrab", value = 1, team = "zombies", model = "" },
    ["npc_zombie_torso"] = { name = "Zombie Torso", value = 1, team = "zombies", model = "" },
    ["npc_barnacle"] = { name = "Barnacle", value = 1, team = "do_not_use", model = "" },
    ["npc_zombie"] = { name = "Zombie", value = 2, team = "zombies", model = "" },
    ["npc_fastzombie_torso"] = { name = "Fast Zombie Torso", value = 2, team = "zombies", model = "" },
    ["npc_manhack"] = { name = "Manhack", value = 3, team = "combine", model = "" },
    ["npc_headcrab_fast"] = { name = "Headcrab Fast", value = 3, team = "zombies", model = "" },
    ["npc_headcrab_poison"] = { name = "Headcrab Poison", value = 3, team = "zombies", model = "" },
    ["npc_antlion"] = { name = "Antlion", value = 3, team = "antlions", model = "" },
    ["npc_fastzombie"] = { name = "Fast Zombie", value = 5, team = "zombies", model = "" },
    ["npc_poisonzombie"] = { name = "Poison Zombie", value = 10, team = "zombies", model = "" }
}

vipd_vips = {
    "npc_elsa", "npc_anna", "npc_alyx", "npc_gman"
}

-- npc_stalker
-- npc_metropolice
-- npc_combine_s
-- npc_rollermine
-- npc_sniper
-- npc_vortigaunt
-- npc_antlionguard
-- npc_strider
-- npc_helicopter
-- npc_combinegunship