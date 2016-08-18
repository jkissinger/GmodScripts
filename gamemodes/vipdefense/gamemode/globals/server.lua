-- Global values
RegisteredNpcCount = 0
RegisteredWeaponCount = 0
NpcsByModel = { }
LowestValueGroundNPC = 1000
LowestValueFlyingNPC = 1000
TaggedEnemy = nil
TaggedAlly = nil

-- ===========================
-- = Configuration Constants =
-- ===========================
-- These are likely to become ConVars or more likely console commands to change them
-- == Level System Constants ==
LevelSystem = true
MaxLevel = 200
MaxTier = 0
-- Adjust costs up quickly, and down slowly
TEMP_BUY_ADJUST_PERCENT = 30
PERM_BUY_ADJUST_PERCENT = 100
NO_BUY_ADJUST_PERCENT = -10
DEFAULT_WEAPON_COST = 20
-- == Spawn System Constants ==
VALID_CONFIG = false
MIN_SPAWN_DISTANCE = 800 -- Minimum distance to spawn from players
MAX_NPCS = 25
MAX_DISTANCE = 500000
MAX_NPCS_PER_PLAYER = 10
MIN_NPC_VALUE = 3
PVP_ENABLED = CreateConVar( "vipd_pvp", "0", FCVAR_REPLICATED )
NODES_PER_GROUP = 500
VIPD_ALLY_CHANCE = 10 --Chance a group is ally
VIPD_VIP_CHANCE = 5
MAX_GROUP_SIZE = 30
GROUP_DISTANCE = 2000
-- == Utility Constants ==
VIPD_LOADOUT_OVERRIDE = false
TELEPORT_COOLDOWN = 30
SOUND_TYPE_HELP = 0
SOUND_TYPE_RESCUE = 1

HELP_SOUND_EXTENSION = "_help.wav"
RESCUE_SOUND_EXTENSION = "_rescued.wav"
MAX_ENEMY_DIVISOR = 20

INITIAL_POINTS = 0