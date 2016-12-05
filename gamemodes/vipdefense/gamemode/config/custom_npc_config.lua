table.insert(vipd_enemy_teams, { name = "Minecraft", disabled = true, outside = true, inside = true })
table.insert(vipd_enemy_teams, { name = "UNLOADED-WW2_Germany", disabled = true,  outside = true, inside = false })
table.insert(vipd_enemy_teams, { name = "Skyrim", outside = true, disabled = true,  inside = true })
table.insert(vipd_enemy_teams, { name = "UNLOADED-Counterstrike", disabled = true,  outside = true, inside = false })
table.insert(vipd_enemy_teams, { name = "UNLOADED-Magical", disabled = true,  outside = true, inside = false })
table.insert(vipd_enemy_teams, { name = "Neon Overwatch", disabled = true,  outside = true, inside = true })
table.insert(vipd_enemy_teams, { name = "Boss", outside = true, disabled = true,  inside = true })
table.insert(vipd_enemy_teams, { name = "Paranoia", outside = true, disabled = true,  inside = false })
table.insert(vipd_enemy_teams, { name = "Dinosaurs", outside = true, disabled = true,  inside = false })
table.insert(vipd_enemy_teams, { name = "Monster", outside = true, disabled = true,  inside = true })

-- ============
-- = Antlions =
-- ============
vipd_npcs["npc_vj_hellion"] = { name = "Hellion", value = 12, teamname = "Antlions"}
vipd_npcs["npc_vj_frostlion"] = { name = "Frostlion", value = 13, teamname = "Antlions"}
vipd_npcs["npc_vj_thunderlion"] = { name = "Hellion", value = 15, teamname = "Antlions"}
vipd_npcs["npc_vj_frostlionguard"] = { name = "Frostlion Guard", value = 50, teamname = "Antlions"}
vipd_npcs["npc_vj_hellionguard"] = { name = "Hellion Guard", value = 60, teamname = "Antlions"}
vipd_npcs["npc_vj_thunderlionguard"] = { name = "Thunderlion Guard", value = 70, teamname = "Antlions"}

-- =============
-- = Overwatch =
-- =============
vipd_npcs["npc_grendelh"] = { value = 15, teamname = "Overwatch" }
vipd_npcs["npc_ewrh"] = { value = 15, teamname = "Overwatch" }
-- Sparbine
vipd_npcs["sc_prisonguard"] = { value = 10, teamname = "Overwatch" }
vipd_npcs["sc_police"] = { value = 20, teamname = "Overwatch" }
vipd_npcs["Sparbine Mark I A"] = { name = "Sparbine Mark I A", value = 20, teamname = "Overwatch" }
vipd_npcs["Sparbine Mark I B"] = { name = "Sparbine Mark I B", value = 20, teamname = "Overwatch" }
vipd_npcs["Sparbine Mark II B"] = { name = "Sparbine Mark II B", value = 30, teamname = "Overwatch" }
vipd_npcs["Sparbine Mark II A"] = { name = "Sparbine Mark II A", value = 30, teamname = "Overwatch" }
vipd_npcs["Sparbine Mark III"] = { name = "Sparbine Mark III", value = 40, teamname = "Overwatch" }
vipd_npcs["Sparbine Mark S"] = { name = "Sparbine Mark S", value = 50, teamname = "Overwatch" }
vipd_npcs["sc_soldier"] = { value = 20, teamname = "disabled" } -- Duplicate of Sparbine
vipd_npcs["sc_supersoldier"] = { value = 35, teamname = "disabled" } -- Duplicate of Sparbine
vipd_npcs["vsupersoldier"] = { value = 15, teamname = "Overwatch" }
vipd_npcs["vpolice"] = { value = 15, teamname = "Overwatch" }
vipd_npcs["vsoldier"] = { value = 15, teamname = "Overwatch" }
vipd_npcs["vprisonguard"] = { value = 15, teamname = "Overwatch" }
--vipd_npcs["necris_m_combine"] = { value = 20, teamname = "disabled" } -- Doesn't work, no weapon?
-- Extra Combine
vipd_npcs["npc_metro_arrest"] = { value = 6, teamname = "Overwatch" }
vipd_npcs["npc_combine_assassin"] = { name = "Combine Assassin", value = 40, teamname = "Overwatch" }
vipd_npcs["npc_combine_synth"] = { name = "Combine Synth", value = 25, teamname = "Overwatch" }
vipd_npcs["npc_combine_synth_elite"] = { name = "Combine Synth Elite", value = 35, teamname = "Overwatch" }
vipd_npcs["npc_combine_shield"] = { value = 15, teamname = "Overwatch" }
vipd_npcs["npc_combine_elite"] = { value = 25, teamname = "Overwatch" }
vipd_npcs["npc_combine_medic"] = { value = 10, teamname = "Overwatch" }
vipd_npcs["npc_combine_overwatch_s"] = { value = 10, teamname = "Overwatch" }
vipd_npcs["npc_combine_prisonguard"] = { value = 8, teamname = "Overwatch" }
vipd_npcs["npc_combine_engineer"] = { value = 15, teamname = "Overwatch" }
vipd_npcs["npc_combine_elite_strider"] = { value = 100, teamname = "Overwatch" }
vipd_npcs["npc_combine_prisonguard_s"] = { value = 10, teamname = "Overwatch" }
vipd_npcs["npc_combine_commander"] = { value = 15, teamname = "Overwatch" }
vipd_npcs["npc_combine_sniper"] = { value = 25, teamname = "Overwatch" }
vipd_npcs["npc_combine_overwatch"] = { value = 15, teamname = "Overwatch" }
vipd_npcs["npc_combine_hg"] = { value = 20, teamname = "Overwatch" }
vipd_npcs["npc_combine_grenadier"] = { value = 15, teamname = "Overwatch" }
vipd_npcs["npc_combine_support"] = { value = 10, teamname = "Overwatch" }
vipd_npcs["npc_combine_cscanner"] = { value = 1, teamname = "Overwatch", flying = true }
vipd_npcs["npc_combine_veteran"] = { value = 20, teamname = "Overwatch" }
vipd_npcs["npc_combine_burner"] = { value = 25, teamname = "Overwatch" }


-- ==================
-- = Neon Overwatch =
-- ==================
vipd_npcs["neon-combine_soldier_prison_guard"] = { value = 8, teamname = "Neon Overwatch" }
vipd_npcs["neon-elite_combine"] = { value = 25, teamname = "Neon Overwatch" }
vipd_npcs["neon-combine_soldier_color5"] = { value = 10, teamname = "Neon Overwatch" }
vipd_npcs["neon-combine_soldier_color1"] = { value = 10, teamname = "Neon Overwatch" }
vipd_npcs["neon-combine_shotgun_soldier"] = { value = 15, teamname = "Neon Overwatch" }
vipd_npcs["neon-combine_soldier_color3"] = { value = 10, teamname = "Neon Overwatch" }
vipd_npcs["Neon Stalker"] = { value = 15, teamname = "Neon Overwatch" }
vipd_npcs["neon-combine_soldier"] = { value = 10, teamname = "Neon Overwatch" }
vipd_npcs["neon-combine_soldier_color4"] = { value = 10, teamname = "Neon Overwatch" }
vipd_npcs["neon-combine_soldier_color2"] = { value = 10, teamname = "Neon Overwatch" }
vipd_npcs["neon-metrocop"] = { name = "Neon Metro Cop", value = 6, teamname = "Overwatch"}

-- ===========
-- = Undead =
-- ===========
vipd_npcs["npc_vj_am"] = { name = "Amputated Zombie", value = 8, teamname = "Undead" }
vipd_npcs["monster_amn_grunt"] = { name = "Grunt", value = 35, teamname = "Undead" }
vipd_npcs["monster_amn_brute"] = { name = "Brute", value = 40, teamname = "Undead" }
vipd_npcs["monster_amn_suitor"] = { name = "Suitor", value = 45, teamname = "Undead" }
vipd_npcs["npc_vj_feeder"] = { name = "Feeder", value = 20, teamname = "Undead" }
vipd_npcs["npc_vj_skeleton_s"] = { name = "Skeleton Soldier", value = 15, teamname = "Undead" }
vipd_npcs["npc_alicehostile"] = { name = "Alice", value = 20, teamname = "Undead" }
vipd_npcs["npc_vj_pen_infect"] = { name = "Pen Infected", value = 0, teamname = "do_not_use" }

-- ==========
-- = Bosses =
-- ==========
vipd_npcs["npc_vj_freddy_kreuger"] = { name = "Freddy Krueger", value = 100, teamname = "Boss"}
vipd_npcs["npc_vj_jason_voorhees"] = { name = "Jason", value = 100, teamname = "Boss"}

-- ============
-- = Paranoia =
-- ============
vipd_npcs["npc_vj_par_zombie1"] = { value = 10, teamname = "Paranoia"}
vipd_npcs["npc_vj_par_bioclone3"] = { value = 15, teamname = "Paranoia" }
vipd_npcs["npc_vj_par_hazmat2"] = { value = 15, teamname = "Paranoia" }
vipd_npcs["npc_vj_par_bioclone2"] = { value = 15, teamname = "Paranoia" }
vipd_npcs["npc_vj_sol_soldiera"] = { value = 15, teamname = "Paranoia" }
vipd_npcs["npc_vj_par_potolonik"] = { value = 15, teamname = "Paranoia" }
vipd_npcs["npc_vj_par_hazmat3"] = { value = 15, teamname = "Paranoia" }
vipd_npcs["npc_vj_ter_terror"] = { value = 25, teamname = "Paranoia" }
vipd_npcs["npc_vj_par_zombie5"] = { value = 10, teamname = "Paranoia" }
vipd_npcs["npc_vj_par_zombie3"] = { value = 10, teamname = "Paranoia" }
vipd_npcs["npc_vj_par_zombie4"] = { value = 10, teamname = "Paranoia" }
vipd_npcs["npc_vj_par_hazmat1"] = { value = 15, teamname = "Paranoia" }
vipd_npcs["npc_vj_par_zombie2"] = { value = 10, teamname = "Paranoia" }
vipd_npcs["npc_vj_par_bioclone1"] = { value = 15, teamname = "Paranoia" }
vipd_npcs["npc_vj_par_biospider"] = { name = "BioSpider", value = 50, teamname = "Paranoia" }
vipd_npcs["npc_vj_par_boss"] = { name = "Zombie Boss", value = 40, teamname = "Paranoia" }
vipd_npcs["npc_vj_par_hazmat"] = { value = 15, teamname = "Paranoia" }
vipd_npcs["npc_vj_par_zombie"] = { value = 15, teamname = "Paranoia" }
vipd_npcs["npc_vj_par_terror"] = { value = 15, teamname = "Paranoia" }
vipd_npcs["npc_vj_par_alpha"] = { value = 15, teamname = "Paranoia" }

-- ===========
-- = Fantasy =
-- ===========
vipd_npcs["npc_vj_ds_artorias"] = { name = "Artorias", value = 200, teamname = "Magical" }
vipd_npcs["npc_vj_ds_darkwraith"] = { name = "Darkwraith", value = 30, teamname = "Magical" }
vipd_npcs["npc_vj_ds_mimic"] = { name = "Mimic", value = 25, teamname = "Magical" }
vipd_npcs["npc_vj_ds_ornstein"] = { name = "Ornstein", value = 100, teamname = "Magical" }

-- ==========
-- = Aliens =
-- ==========
vipd_npcs["npc_vj_parasite"] = { name = "Parasite", value = 25, teamname = "Aliens" }
vipd_npcs["npc_vj_spherecreature"] = { name = "Sphere Creature", value = 3, teamname = "Aliens" }
vipd_npcs["npc_vj_keeper"] = { name = "Keeper", value = 20, teamname = "Aliens" }

-- =============
-- = Minecraft =
-- =============
vipd_npcs["npc_mine_cat"] = { name = "Ocelot", value = 1, teamname = VipdAllyTeam.name}
vipd_npcs["npc_mine_chicken"] = { name = "Chicken", value = 1, teamname = VipdAllyTeam.name}
vipd_npcs["npc_mine_cow"] = { name = "Cow", value = 1, teamname = VipdAllyTeam.name}
vipd_npcs["npc_mine_creeper"] = { name = "Creeper", value = 10, teamname = "Minecraft"}
vipd_npcs["npc_mine_irongolem"] = { name = "Iron Golem", value = 15, teamname = VipdVipTeam.name}
vipd_npcs["npc_mine_mooshroom"] = { name = "Mooshroom", value = 2, teamname = VipdAllyTeam.name}
vipd_npcs["npc_mine_pig"] = { name = "Pig", value = 1, teamname = VipdAllyTeam.name}
vipd_npcs["npc_mine_sheep"] = { name = "Sheep", value = 1, teamname = VipdAllyTeam.name}
vipd_npcs["npc_mine_silverfish"] = { name = "Silverfish", value = 3, teamname = "Minecraft"}
vipd_npcs["npc_mine_skeleton"] = { name = "Skeleton", value = 10, teamname = "Minecraft"}
vipd_npcs["npc_mine_slime"] = { name = "Slime", value = 3, teamname = "Minecraft"}
vipd_npcs["npc_mine_slime_big"] = { name = "Big Slime", value = 8, teamname = "Minecraft"}
vipd_npcs["npc_mine_slime_huge"] = { name = "Huge Slime", value = 12, teamname = "Minecraft"}
vipd_npcs["npc_mine_snowgolem"] = { name = "Snow Golem", value = 2, teamname = VipdAllyTeam.name}
vipd_npcs["npc_mine_spider"] = { name = "Spider", value = 10, teamname = "Minecraft"}
vipd_npcs["npc_mine_villager"] = { name = "Villager", value = 2, teamname = VipdAllyTeam.name}
vipd_npcs["npc_mine_ss"] = { name = "Spider Jockey", value = 15, teamname = "Minecraft"}
vipd_npcs["npc_mine_witch"] = { name = "Witch", value = 12, teamname = "Minecraft"}
vipd_npcs["npc_mine_wolf"] = { name = "Wolf", value = 5, teamname = "Minecraft"}
vipd_npcs["npc_mine_zombie"] = { name = "Zombie", value = 4, teamname = "Minecraft"}
vipd_npcs["npc_mine_dzhigurper"] = { value = 10, teamname = "Minecraft"}
vipd_npcs["npc_mine_wolffri"] = { value = 1, teamname = VipdAllyTeam.name}

-- ==========
-- = Skyrim =
-- ==========
vipd_npcs["Draugr"] = { name = "Draugr", value = 3, teamname = "Skyrim"}
vipd_npcs["Restless Draugr"] = { name = "Restless Draugr", value = 15, teamname = "Skyrim"}
vipd_npcs["Draugr Deathlord"] = { name = "Draugr Deathlord", value = 40, teamname = "Skyrim"}
vipd_npcs["Draugr Overlord"] = { name = "Draugr Overlord", value = 25, teamname = "Skyrim"}
vipd_npcs["Draugr Scourge"] = { name = "Draugr Scourge", value = 20, teamname = "Skyrim"}
vipd_npcs["Draugr Wight"] = { name = "Draugr Wight", value = 20, teamname = "Skyrim"}
vipd_npcs["Dwarven Centurion"] = { name = "Dwarven Centurion", value = 50, teamname = "Skyrim"}
vipd_npcs["Arvak"] = { name = "Arvak", value = 15, teamname = "Animals"}
vipd_npcs["Horse"] = { name = "Horse", value = 15, teamname = "Animals"}
vipd_npcs["Ash Hopper"] = { name = "Ash Hopper", value = 5, teamname = "Skyrim"}
vipd_npcs["Chaurus"] = { name = "Chaurus", value = 25, teamname = "Skyrim"}
vipd_npcs["Dwarven Sphere"] = { name = "Dwarven Sphere", value = 30, teamname = "Skyrim"}
vipd_npcs["Dwarven Spider"] = { name = "Dwarven Spider", value = 10, teamname = "Skyrim"}
vipd_npcs["Falmer"] = { name = "Falmer", value = 20, teamname = "Skyrim"}
vipd_npcs["Falmer Gloomlurker"] = { name = "Falmer Gloomlurker", value = 20, teamname = "Skyrim"}
vipd_npcs["Falmer Nightprowler"] = { name = "Falmer Nightprowler", value = 20, teamname = "Skyrim"}
vipd_npcs["Chaurus Hunter"] = { name = "Chaurus Hunter", value = 40, teamname = "Skyrim", flying = true}
vipd_npcs["Falmer Shadowmaster"] = { name = "Falmer Shadowmaster", value = 18, teamname = "Skyrim"}
vipd_npcs["Falmer Skulker"] = { name = "Falmer Skulker", value = 14, teamname = "Skyrim"}
vipd_npcs["Flame Atronach"] = { name = "Flame Atronarch", value = 25, teamname = "Skyrim", flying = true}
vipd_npcs["Frost Atronach"] = { name = "Frost Atronarch", value = 30, teamname = "Skyrim"}
vipd_npcs["Frostbite Spider"] = { name = "Frostbite Spider", value = 25, teamname = "Skyrim"}
vipd_npcs["Mud Crab"] = { name = "Mud Crab", value = 10, teamname = "Skyrim"}
vipd_npcs["Legendary Mud Crab"] = { name = "Legendary Mud Crab", value = 25, teamname = "Skyrim"}
vipd_npcs["Small Frostbite Spider"] = { name = "Small Frostbite Spider", value = 4, teamname = "Skyrim"}
--Dragons
vipd_npcs["Dragon"] = { name = "Dragon", value = 50, teamname = "Skyrim", flying = true}
vipd_npcs["Ancient Dragon"] = { name = "Ancient Dragon", value = 75, teamname = "Skyrim", flying = true}
vipd_npcs["Alduin"] = { name = "Alduin", value = 100, teamname = "Skyrim", flying = true}
vipd_npcs["Frost Dragon"] = { name = "Frost Dragon", value = 75, teamname = "Skyrim", flying = true}
vipd_npcs["Skeletal Dragon"] = { name = "Skeletal Dragon", value = 75, teamname = "Skyrim", flying = true}
vipd_npcs["Blood Dragon"] = { name = "Blood Dragon", value = 75, teamname = "Skyrim", flying = true}
vipd_npcs["Revered Dragon"] = { name = "Revered Dragon", value = 75, teamname = "Skyrim", flying = true}
-- Duplicate with space?
vipd_npcs["Revered Dragon "] = { name = "Revered Dragon", value = 75, teamname = "Skyrim", flying = true}
vipd_npcs["Odahviing"] = { name = "Odahviing", value = 50, teamname = "Skyrim", flying = true}
vipd_npcs["Paarthurnax"] = { name = "Paarthurnax", value = 100, teamname = "Skyrim", flying = true}
vipd_npcs["Elder Dragon"] = { name = "Elder Dragon", value = 100, teamname = "Skyrim", flying = true}
--Unknown??
vipd_npcs["npc_dragon_serpentine"] = { name = "Serpentine Dragon", value = 100, teamname = "Skyrim", flying = true}

-- ===============
-- = WW2_Germany =
-- ===============
vipd_npcs["npc_german_schutze"] = { name = "German Schutze", value = 15, teamname = "WW2_Germany"}
vipd_npcs["npc_german_paratrooper"] = { name = "German Paratrooper", value = 15, teamname = "WW2_Germany"}
vipd_npcs["npc_vj_mili_tiger_red"] = { name = "Tiger Tank", value = 50, teamname = "WW2_Germany"}
vipd_npcs["npc_german_grenadier"] = { name = "German Grenadier", value = 15, teamname = "WW2_Germany"}
vipd_npcs["npc_german_officer"] = { name = "German Officer", value = 15, teamname = "WW2_Germany"}
vipd_npcs["npc_vj_mili_german"] = { name = "German Military", value = 15, teamname = "WW2_Germany"}
vipd_npcs["npc_german_sentry"] = { name = "German Sentry", value = 15, teamname = "WW2_Germany"}
vipd_npcs["sent_vj_mili_randger"] = { name = "German Soldier", value = 15, teamname = "WW2_Germany"}
vipd_npcs["npc_vj_mili_waffenss"] = { name = "German Waffen SS", value = 15, teamname = "WW2_Germany"}
vipd_npcs["npc_vj_mili_wehrmacht"] = { name = "German Wehrmacht", value = 15, teamname = "WW2_Germany"}
vipd_npcs["npc_german_gestapo"] = { name = "German Gestapo", value = 15, teamname = "WW2_Germany"}
--Not working? 
vipd_npcs["npc_nazi_storm_elite"] = { name = "German Elite Storm", value = 15, teamname = "do_not_use"}
vipd_npcs["npc_panzergrenadier"] = { name = "German Panzergrenadier", value = 10, teamname = "do_not_use"}
vipd_npcs["npc_german_sniper"] = { name = "German Sniper", value = 10, teamname = "do_not_use"}
-- Ally  
vipd_npcs["npc_vj_milifri_tiger_red"] = { name = "Ally Tiger Tank", value = -100, teamname = "do_not_use" }
vipd_npcs["npc_vj_milifri_waffenss"] = { name = "Ally Waffen SS", value = -10, teamname = "do_not_use"}
vipd_npcs["sent_vj_milifri_randger"] = { name = "Ally German Soldier", value = -10, teamname = "do_not_use"}
vipd_npcs["npc_vj_milifri_wehrmacht"] = { name = "Ally Wehrmacht", value = -10, teamname = "do_not_use"}
vipd_npcs["npc_vj_milifri_german"] = { name = "Ally German Soldier", value = -10, teamname = "do_not_use"}

-- =================
-- = Counterstrike =
-- =================
--vipd_npcs["npc_vj_css_arctic"] = { name = "Arctic", value = 15, teamname = "Counterstrike"}
--vipd_npcs["npc_vj_css_gasmask"] = { name = "Gas Mask", value = 15, teamname = "Counterstrike"}
--vipd_npcs["npc_vj_css_guerilla"] = { name = "Guerilla", value = 15, teamname = "Counterstrike"}
--vipd_npcs["npc_vj_css_leet"] = { name = "Leet", value = 15, teamname = "Counterstrike"}
--vipd_npcs["npc_vj_css_phoenix"] = { name = "Phoenix", value = 15, teamname = "Counterstrike"}
--vipd_npcs["npc_vj_css_riot"] = { name = "Riot", value = 15, teamname = "Counterstrike"}
--vipd_npcs["npc_vj_css_swat"] = { name = "SWAT", value = 15, teamname = "Counterstrike"}
--vipd_npcs["npc_vj_css_urban"] = { name = "Urban", value = 15, teamname = "Counterstrike"}

-- ===========
-- = Dinosaurs =
-- ===========
vipd_npcs["npc_dino_brah"] = { value = 25, teamname = "Dinosaurs" }
vipd_npcs["npc_dino_allosaurus"] = { value = 35, teamname = "Dinosaurs" }
vipd_npcs["npc_dino_triceratops"] = { value = 20, teamname = "Dinosaurs" }
vipd_npcs["npc_dino_rugops"] = { value = 15, teamname = "Dinosaurs" }
vipd_npcs["npc_dino_carnotaurus"] = { value = 25, teamname = "Dinosaurs" }
vipd_npcs["npc_dino_hadrosaur"] = { value = 25, teamname = "Dinosaurs" }
vipd_npcs["npc_dino_dilophosaurus"] = { value = 15, teamname = "Dinosaurs" }
vipd_npcs["npc_dino_trex_l2"] = { value = 55, teamname = "Dinosaurs" }
vipd_npcs["npc_dino_spino"] = { value = 45, teamname = "Dinosaurs" }
vipd_npcs["npc_dino_gigano"] = { value = 65, teamname = "Dinosaurs" }
vipd_npcs["npc_dino_carcharodontosaurus"] = { value = 25, teamname = "Dinosaurs" }
vipd_npcs["npc_dino_trex_jp"] = { value = 45, teamname = "Dinosaurs" }
vipd_npcs["npc_dino_cerato"] = { value = 35, teamname = "Dinosaurs" }
vipd_npcs["npc_dino_raptor_t"] = { value = 30, teamname = "Dinosaurs" }
vipd_npcs["npc_dino_spino_jp"] = { value = 25, teamname = "Dinosaurs" }
vipd_npcs["npc_dino_trex"] = { value = 55, teamname = "Dinosaurs" }
vipd_npcs["npc_dino_trex_huge"] = { value = 85, teamname = "Dinosaurs" }
vipd_npcs["npc_dino_scarface_momma"] = { value = 35, teamname = "Dinosaurs" }
vipd_npcs["npc_dino_raptor_jp"] = { value = 25, teamname = "Dinosaurs" }


-- ===========
-- = Unknown =
-- ===========
vipd_npcs["sent_vj_test"] = { name = "VJ Test Sent", value = 15, teamname = "do_not_use"}
vipd_npcs["npc_soma_robothead"] = { name = "Soma Robothead", value = 25, teamname = "disabled"}

-- =============
-- = Allies =
-- =============
vipd_npcs["npc_vj_css_hostage1"] = { name = "Hostage 1", value = -10, teamname = VipdAllyTeam.name }
vipd_npcs["npc_vj_css_hostage2"] = { name = "Hostage 2", value = -10, teamname = VipdAllyTeam.name }
vipd_npcs["npc_vj_css_hostage3"] = { name = "Hostage 3", value = -10, teamname = VipdAllyTeam.name }
vipd_npcs["npc_vj_css_hostage4"] = { name = "Hostage 4", value = -10, teamname = VipdAllyTeam.name }

-- =================
-- = Player Models =
-- =================
--vipd_npcs["Anticitizen_one"] = { name = "Gordon Freeman", value = -100, teamname = VipdVipTeam.name }
vipd_npcs["npc_cwironmangood"] = { name = "Iron Man", value = -100, teamname = VipdVipTeam.name }
vipd_npcs["npc_cwcrossbonesgood"] = { name = "Winter Soldier", value = -100, teamname = VipdVipTeam.name }
--vipd_npcs["npc_patriotgood"] = { name = "Iron Patriot", value = -100, teamname = VipdVipTeam.name }
vipd_npcs["npc_elsa"] = { name = "Elsa", value = -100, teamname = VipdVipTeam.name }
vipd_npcs["npc_anna"] = { name = "Anna", value = -100, teamname = VipdVipTeam.name }
--vipd_npcs["npc_ironmangood"] = { name = "Iron Man", value = -100, teamname = VipdVipTeam.name }
vipd_npcs["npc_cwblackpanthergood"] = { name = "Black Panther", value = -100, teamname = VipdVipTeam.name }
vipd_npcs["npc_cwcaptainamericagood"] = { name = "Captain America", value = -100, teamname = VipdVipTeam.name }
vipd_npcs["npc_link_weapons"] = { name = "Link", value = -100, teamname = "do_not_use" }
vipd_npcs["npc_grendelf"] = { name = "Grendel", value = -100, teamname = "do_not_use" }
vipd_npcs["npc_AkmHarley"] = { name = "Arkham Harley", value = -100, teamname = "do_not_use" }
vipd_npcs["npc_aliceally"] = { name = "Alice", value = -100, teamname = "do_not_use" }
--vipd_npcs["necris_m_rebel"] = { name = "Necris", value = -100, teamname = "do_not_use" }
vipd_npcs["npc_ewrf"] = { name = "EWRF", value = -100, teamname = "do_not_use" }
vipd_npcs["npc_link"] = { name = "Link", value = -100, teamname = "do_not_use" }
vipd_npcs["npc_odessa"] = { name = "Odessa", value = -100, teamname = "do_not_use" }
vipd_npcs["npc_aliceally"] = { name = "Alice", value = -100, teamname = "do_not_use" }
--vipd_npcs["npc_AKAK"] = { name = "AKAK", value = -10, teamname = "do_not_use" }
-- Bad 
--vipd_npcs["npc_patriotbad"] = { name = "Iron Patriot", value = -100, teamname = "do_not_use" }
vipd_npcs["npc_cwcrossbonesbad"] = { name = "Winter Soldier", value = -100, teamname = "do_not_use" }
vipd_npcs["npc_cwcaptainamericabad"] = { name = "Captain America", value = -100, teamname = "do_not_use" }
vipd_npcs["npc_cwironmanbad"] = { name = "Iron Man", value = -100, teamname = "do_not_use" }
--vipd_npcs["npc_ironmanbad"] = { name = "Iron Man", value = -100, teamname = "do_not_use" }
vipd_npcs["npc_cwblackpantherbad"] = { name = "Black Panther", value = -100, teamname = "do_not_use" }
vipd_npcs["npc_vj_lich_king"] = { value = 15, teamname = "do_not_use" }

-- =========
-- == NEW ==
-- =========
vipd_npcs["npc_sw_magnag_combined_f"] = { value = 15, teamname = "Overwatch" }
vipd_npcs["npc_sw_magnag_season4_h"] = { value = 15, teamname = "Overwatch" }
vipd_npcs["npc_sw_magnag_combined_h"] = { value = 15, teamname = "Overwatch" }
vipd_npcs["npc_sw_magnag_trainer_h"] = { value = 15, teamname = "Overwatch" }

vipd_npcs["Mortar Synth"] = { value = 15, teamname = "Alien" }
vipd_npcs["Poisonsquid"] = { value = 15, teamname = "Alien" }
vipd_npcs["Chumtoad"] = { value = 15, teamname = "Alien" }
vipd_npcs["Kingpin"] = { value = 15, teamname = "Alien" }
vipd_npcs["Stukabat"] = { value = 15, teamname = "Alien" }
vipd_npcs["sw_alien_cutbug"] = { value = 15, teamname = "Alien" }
vipd_npcs["Bullsquid"] = { value = 15, teamname = "Alien" }
vipd_npcs["Devilsquid"] = { value = 15, teamname = "Alien" }
vipd_npcs["Frostsquid"] = { value = 15, teamname = "Alien" }
vipd_npcs["Pit Drone"] = { value = 15, teamname = "Alien" }

vipd_npcs["Dr Keller"] = { value = 15, teamname = "Monster" } -- GOOD GUY
vipd_npcs["Dr Rosenberg"] = { value = 15, teamname = "Monster" } -- Good guy?
vipd_npcs["Scientist"] = { value = 15, teamname = "Monster" }
vipd_npcs["Government Man"] = { value = 15, teamname = "Monster" }

vipd_npcs["Zombie Security Officer"] = { value = 15, teamname = "Monster" }
vipd_npcs["Alien Slave"] = { value = 15, teamname = "Monster" }
vipd_npcs["Shock Trooper"] = { value = 15, teamname = "Monster" }
vipd_npcs["HECU Marine"] = { value = 15, teamname = "Monster" }
vipd_npcs["Cockroach"] = { value = 1, teamname = "Monster" }
vipd_npcs["Leech"] = { value = 3, teamname = "Monster" }
vipd_npcs["Panthereye"] = { value = 15, teamname = "Monster" }
vipd_npcs["Baby Headcrab"] = { value = 1, teamname = "Monster" }
vipd_npcs["Archer"] = { value = 15, teamname = "Monster" }
vipd_npcs["Security Officer"] = { value = 15, teamname = "Monster" }
vipd_npcs["Tor"] = { value = 15, teamname = "Monster" }
vipd_npcs["Tentacle"] = { value = 15, teamname = "Monster" }
vipd_npcs["Voltigore"] = { value = 15, teamname = "Monster" }
vipd_npcs["Tentacle"] = { value = 15, teamname = "Monster" }
vipd_npcs["HECU Sergeant"] = { value = 15, teamname = "Monster" }
vipd_npcs["Baby Voltigore"] = { value = 15, teamname = "Monster" }
vipd_npcs["Small Mounted Turret"] = { value = 15, teamname = "Monster" }
vipd_npcs["Snark"] = { value = 15, teamname = "Monster" }
vipd_npcs["Headcrab"] = { value = 3, teamname = "Monster" }
vipd_npcs["Decay Sentry"] = { value = 15, teamname = "Monster" }
vipd_npcs["Alien Grunt"] = { value = 15, teamname = "Monster" }
vipd_npcs["Gargantua"] = { value = 30, teamname = "Monster" }
vipd_npcs["Gene Worm"] = { value = 100, teamname = "Monster" }
vipd_npcs["Zombie Scientist"] = { value = 15, teamname = "Monster" }
vipd_npcs["Ichthyosaur"] = { value = 3, teamname = "Monster" } -- Fish
vipd_npcs["Shock Roach"] = { value = 15, teamname = "Monster" }
vipd_npcs["Large Mounted Turret"] = { value = 15, teamname = "Monster" }
vipd_npcs["Nihilanth"] = { value = 15, teamname = "Monster" }
vipd_npcs["Sentry"] = { value = 15, teamname = "Monster" }
vipd_npcs["Penguin"] = { value = 2, teamname = "Monster" }
vipd_npcs["Zombie HECU Marine"] = { value = 15, teamname = "Monster" }
vipd_npcs["Baby Gargantua"] = { value = 10, teamname = "Monster" }
vipd_npcs["Fat Security Officer"] = { value = 15, teamname = "Monster" }
vipd_npcs["Houndeye"] = { value = 15, teamname = "Monster" }
vipd_npcs["Gonome"] = { value = 8, teamname = "Monster" }
vipd_npcs["Pit Worm"] = { value = 15, teamname = "Monster" }

vipd_npcs["Alien Controller"] = { value = 15, teamname = "Monster", flying = true }