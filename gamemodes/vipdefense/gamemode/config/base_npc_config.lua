vipd_enemy_teams = { }
table.insert(vipd_enemy_teams, { name = "Undead", disabled = false,  outside = false, inside = true })
table.insert(vipd_enemy_teams, { name = "Antlions", disabled = false,  outside = true, inside = false })
table.insert(vipd_enemy_teams, { name = "Overwatch", disabled = false,  outside = true, inside = true })
table.insert(vipd_enemy_teams, { name = "Aliens", disabled = false,  outside = true, inside = false })
table.insert(vipd_enemy_teams, { name = "Animals", disabled = true,  outside = true, inside = true })

vipd_npcs = { }
-- ===========
-- = Undead =
-- ===========
vipd_npcs["npc_headcrab"] = { name = "Headcrab", value = 1, teamname = "Undead"}
vipd_npcs["npc_zombie_torso"] = { name = "Zombie Torso", value = 2, teamname = "Undead"}
vipd_npcs["npc_zombie"] = { name = "Zombie", value = 2, teamname = "Undead"}
vipd_npcs["npc_fastzombie_torso"] = { name = "Fast Zombie Torso", value = 3, teamname = "Undead"}
vipd_npcs["npc_headcrab_fast"] = { name = "Headcrab Fast", value = 2, teamname = "Undead"}
vipd_npcs["npc_headcrab_black"] = { name = "Headcrab Poison", value = 3, teamname = "Undead"}
vipd_npcs["npc_fastzombie"] = { name = "Fast Zombie", value = 6, teamname = "Undead"}
vipd_npcs["npc_poisonzombie"] = { name = "Poison Zombie", value = 12, teamname = "Undead"}
vipd_npcs["npc_zombine"] = { name = "Zombine", value = 10, override = true, teamname = "Undead"}

-- =============
-- = Antlions =
-- =============
vipd_npcs["npc_antlion"] = { name = "Antlion", value = 4, teamname = "Antlions"}
vipd_npcs["npc_antlionguard"] = { name = "Antlion Guard", value = 40, teamname = "Antlions"}

-- =============
-- = Overwatch =
-- =============
vipd_npcs["npc_metropolice"] = { name = "Metro Police", value = 2, teamname = "Overwatch"}
vipd_npcs["npc_combine_s"] = { name = "Combine Soldier", value = 6, teamname = "Overwatch"}
vipd_npcs["CombinePrison"] = { name = "Combine Prison Guard", value = 8, teamname = "Overwatch"}
vipd_npcs["PrisonShotgunner"] = { name = "Combine Prison Shotgunner", value = 8, teamname = "Overwatch"}
vipd_npcs["ShotgunSoldier"] = { name = "Combine Shotgun Soldier", value = 10, teamname = "Overwatch"}
vipd_npcs["CombineElite"] = { name = "Combine Elite", value = 12, teamname = "Overwatch"}
vipd_npcs["npc_hunter"] = { name = "Hunter", value = 20, override = true, teamname = "Overwatch"}

--Striders can't fly but they spawn on flying nodes
vipd_npcs["npc_strider"] = { name = "Strider", value = 40, teamname = "Overwatch", flying = true}
vipd_npcs["npc_combinegunship"] = { name = "Combine Gunship", value = 70, teamname = "Overwatch", flying = true}
vipd_npcs["npc_helicopter"] = { name = "Combine Helicopter", value = 60, teamname = "Overwatch", flying = true}
vipd_npcs["npc_manhack"] = { name = "Manhack", value = 6, teamname = "Overwatch", flying = true}
-- Testing
vipd_npcs["npc_cscanner"] = { name = "Camera Scanner", value = 1, teamname = "Overwatch", flying = true }
vipd_npcs["npc_clawscanner"] = { name = "Camera Scanner", value = 1, teamname = "Overwatch", flying = true }
-- Disabled
vipd_npcs["npc_combine_camera"] = { name = "Combine Camera", value = 1, teamname = "disabled", flying = true}
vipd_npcs["npc_rollermine"] = { name = "Rollermine", value = 0, teamname = "disabled" }

-- ==========
-- = Aliens =
-- ==========
vipd_npcs["npc_vortigaunt"] = { name = "Evil Vortigaunt", value = 15, teamname = VipdVipTeam.name}
vipd_npcs["VortigauntSlave"] = { name = "Vortigaunt Slave", value = 4, teamname = VipdAllyTeam.name}
vipd_npcs["npc_stalker"] = { name = "Stalker", value = 10, teamname = "Aliens"}

-- =============
-- = Animals =
-- =============
vipd_npcs["npc_crow"] = { name = "Crow", value = 1, teamname = "Animals", flying = true}
vipd_npcs["npc_pigeon"] = { name = "Pigeon", value = 1, teamname = "Animals", flying = true}
vipd_npcs["npc_seagull"] = { name = "Seagull", value = 1, teamname = "Animals", flying = true}

-- ==============
-- = Do not use =
-- ==============
vipd_npcs["npc_barnacle"] = { name = "Barnacle", value = 2, teamname = "do_not_use"}
vipd_npcs["npc_turret_ceiling"] = { name = "Ceiling Turret", value = 10, teamname = "do_not_use"}
vipd_npcs["npc_turret_floor"] = { name = "Turret Floor", value = 10, teamname = "do_not_use"}
vipd_npcs["npc_tf2_ghost"] = { name = "Ghost", value = -10, teamname = "do_not_use" }

-- ============
-- = Citizens =
-- ============
vipd_npcs["npc_citizen"] = { name = "Citizen", value = -10, teamname = VipdAllyTeam.name }
vipd_npcs["Refugee"] = { name = "Refugee", value = -10, teamname = VipdAllyTeam.name }
vipd_npcs["Rebel"] = { name = "Rebel", value = -10, teamname = VipdAllyTeam.name }
vipd_npcs["Medic"] = { name = "Medic", value = -10, teamname = VipdAllyTeam.name }

-- ========
-- = VIPs =
-- ========
vipd_npcs["npc_mossman"] = { value = -10, teamname = VipdVipTeam.name }
vipd_npcs["npc_kleiner"] = { value = -10, teamname = "do_not_use" }--VipdVipTeam.name }
vipd_npcs["npc_gman"] = { value = -10, teamname = "do_not_use" }
vipd_npcs["npc_breen"] = { value = -10, teamname = "do_not_use" }--VipdVipTeam.name }
vipd_npcs["npc_dog"] = { value = -10, teamname = "do_not_use" }--VipdVipTeam.name }
vipd_npcs["npc_eli"] = { value = -10, teamname = "do_not_use" }--VipdVipTeam.name }
vipd_npcs["npc_alyx"] = { value = -10, teamname = "do_not_use" }--VipdVipTeam.name }
vipd_npcs["npc_barney"] = { value = -10, teamname = VipdVipTeam.name }
vipd_npcs["npc_monk"] = { value = -10, teamname = VipdVipTeam.name }

-- These will likely be detected as "killed" after despawning so don't use since they can't be killed anyway
vipd_npcs["npc_combinedropship"] = { name = "Combine Dropship", value = 1, teamname = "do_not_use"}
-- spawned by poison zombie
vipd_npcs["npc_headcrab_poison"] = { name = "Headcrab Poison", value = 3, override = true, teamname = "do_not_use"}
