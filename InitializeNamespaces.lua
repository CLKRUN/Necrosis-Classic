Localization = {}

NECROSIS_ID = "Necrosis"

Necrosis = {
	Config = {},
	CurrentEnv = {
		ChatPrefix = "necrosis-classic",
		PlayerGuid = UnitGUID("player"),
		PlayerName = UnitName("player"),
		PlayerFullName = nil,
		InParty = false,
		InRaid = false,
		SpellCast = {}
	},
	Gui = {},
	Speech = {},
	Translation = {},
	Unit = {},
	Debug = {
		init_path 		= false, -- notable points as Necrosis starts
		events 			= false, -- various events tracked, chatty but informative; overlap with spells_cast
		spells_init 	= false, -- setting spell data and highest and helper tables
		spells_cast 	= false, -- spells as they are cast and some resulting actions and auras; overlap with events
		timers 			= false	, -- track as they are created and removed
		buttons 		= false, -- buttons and menus as they are created and updated
		bags			= false, -- what is found in bags and shard management - could be very chatty on large, full bags
		tool_tips		= false, -- spell info that goes into tool tips
		speech			= false, -- steps to produce the 'speech' when summoning
	}
}

Necrosis.Data = {
	Version = NecrosisCompat.GetAddOnMetadata("Necrosis-Classic", "Version"),
	AppName = "Necrosis Classic",
	LastConfig = 20191125
}
Necrosis.Data.Label = Necrosis.Data.AppName.." "..Necrosis.Data.Version


-- Global variables || Variables globales
NecrosisConfig = {}
