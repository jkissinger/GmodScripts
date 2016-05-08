--TODO: Read config from a properties file instead of lua
vipd_weapons = {
    ["none"] = { name = "No weapon", tier = -1, npcValue = 0, cost = 0 },
    ["weapon_fists"] = { name = "Fists", tier = 0, npcValue = 1, cost = 0 },
    ["weapon_physcannon"] = { name = "Gravity Gun", tier = 1, npcValue = 1, cost = 10 },
    ["weapon_stunstick"] = { name = "Stunstick", tier = 1, npcValue = 1, cost = 15 },
    ["weapon_crowbar"] = { name = "Crowbar", tier = 1, npcValue = 1, cost = 20 },
    ["weapon_pistol"] = { name = "Pistol", tier = 2, npcValue = 2, cost = 10 },
    ["weapon_shotgun"] = { name = "Shotgun", tier = 3, npcValue = 8, cost = 25 },
    ["weapon_smg1"] = { name = "SMG", tier = 4, npcValue = 4, cost = 20 },
    ["weapon_357"] = { name = "Magnum", tier = 5, npcValue = 4, cost = 25 },
    ["weapon_ar2"] = { name = "AR2 Rifle", tier = 6, npcValue = 10, cost = 40 },
    ["weapon_frag"] = { name = "Frag", tier = 7, npcValue = 5, cost = 60 },
    ["weapon_crossbow"] = { name = "Crossbow", tier = 8, npcValue = 10, cost = 60 },
    ["weapon_rpg"] = { name = "RPG", tier = 9, npcValue = 15, cost = 100 }
}

-- ================
-- =    Items     =
-- ================
vipd_weapons["item_battery"] = { name = "Suit Battery", tier = -1, npcValue = 0, cost = 10, max_item_count = 7 }
vipd_weapons["item_healthkit"] = { name = "Health Kit", tier = -1, npcValue = 0, cost = 10, max_item_count = 0 }

vipd_enemy_teams = {
    { name = "Zombies", outside = false, inside = true }
    ,{ name = "Antlions", outside = true, inside = false }
    ,{ name = "Overwatch", outside = true, inside = true }
    ,{ name = "Other", outside = false, inside = true }
    ,{ name = "Skyrim", outside = true, inside = true }
--    ,{ name = "Minecraft", outside = true, inside = true }
}

vipd_npcs = { }
-- Team Zombies
vipd_npcs["npc_headcrab"] = { name = "Headcrab", value = 1, team = "Zombies"}
vipd_npcs["npc_zombie_torso"] = { name = "Zombie Torso", value = 2, team = "Zombies"}
vipd_npcs["npc_zombie"] = { name = "Zombie", value = 2, team = "Zombies"}
vipd_npcs["npc_fastzombie_torso"] = { name = "Fast Zombie Torso", value = 3, team = "Zombies"}
vipd_npcs["npc_headcrab_fast"] = { name = "Headcrab Fast", value = 2, team = "Zombies"}
vipd_npcs["npc_headcrab_black"] = { name = "Headcrab Poison", value = 3, team = "Zombies"}
vipd_npcs["npc_fastzombie"] = { name = "Fast Zombie", value = 6, team = "Zombies"}
vipd_npcs["npc_poisonzombie"] = { name = "Poison Zombie", value = 12, team = "Zombies"}
vipd_npcs["npc_zombine"] = { name = "Zombine", value = 10, team = "Zombies"}
--, team Antlions
vipd_npcs["npc_antlion"] = { name = "Antlion", value = 4, team = "Antlions"}
vipd_npcs["npc_antlionguard"] = { name = "Antlion Guard", value = 40, team = "Antlions"}
--, team Overwatch (Combine)
vipd_npcs["npc_metropolice"] = { name = "Metro Police", value = 2, team = "Overwatch"}
vipd_npcs["npc_combine_s"] = { name = "Combine Soldier", value = 4, team = "Overwatch"}
vipd_npcs["CombineElite"] = { name = "Combine Elite", value = 10, team = "Overwatch"}
vipd_npcs["npc_strider"] = { name = "Strider", value = 40, team = "Overwatch", flying = true}
vipd_npcs["CombinePrison"] = { name = "Combine Prison Guard", value = 5, team = "Overwatch"}
vipd_npcs["PrisonShotgunner"] = { name = "Combine Prison Shotgunner", value = 5, team = "Overwatch"}
vipd_npcs["ShotgunSoldier"] = { name = "Combine Shotgun Soldier", value = 10, team = "Overwatch"}
-- Disabled because they don't give credit for kills
--vipd_npcs["npc_combinegunship"] = { name = "Combine Gunship", value = 70, team = "Overwatch", flying = true}
--vipd_npcs["npc_helicopter"] = { name = "Combine Helicopter", value = 60, team = "Overwatch", flying = true }
vipd_npcs["npc_manhack"] = { name = "Manhack", value = 6, team = "Overwatch", flying = true}
--, team Other (Vortigaunt and Stalker)
vipd_npcs["npc_vortigaunt"] = { name = "Evil Vortigaunt", value = 15, team = "Other"}
vipd_npcs["VortigauntSlave"] = { name = "Vortigaunt Slave", value = 4, team = "Other"}
vipd_npcs["npc_stalker"] = { name = "Stalker", value = 10, team = "Other"}
-- Unused by defense system, but could appear in other ways
vipd_npcs["npc_barnacle"] = { name = "Barnacle", value = 1, team = "do_not_use"}
vipd_npcs["npc_citizen"] = { name = "Citizen", value = -10, team = "do_not_use" }
vipd_npcs["npc_headcrab_poison"] = { name = "Headcrab Poison", value = 3, team = "do_not_use"}

vipd_vips = {
    { name = "Elsa", class = "npc_elsa" },
    { name = "Anna", class = "npc_anna" },
    { name = "", class = "npc_alyx" },
    { name = "", class = "npc_gman" },
    { name = "", class = "npc_barney" },
    { name = "", class = "npc_eli" }
}
