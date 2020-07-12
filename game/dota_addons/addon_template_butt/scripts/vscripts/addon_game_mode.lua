_G.ADDON_FOLDER = debug.getinfo(1,"S").source:sub(2,-37)
_G.PUBLISH_DATA = LoadKeyValues(ADDON_FOLDER:sub(5,-16).."publish_data.txt") or {}
_G.WORKSHOP_TITLE = PUBLISH_DATA.title or "Dota 2 but..."-- LoadKeyValues(debug.getinfo(1,"S").source:sub(7,-53).."publish_data.txt").title 
_G.MAX_LEVEL = 30

_G.GameMode = _G.GameMode or class({})

require("internal/utils/util")
require("internal/init")

require("internal/courier") -- EditFilterToCourier called from internal/filters

require("internal/utils/butt_api")
require("internal/utils/custom_gameevents")
require("internal/utils/particles")
require("internal/utils/timers")
-- require("internal/utils/notifications") -- will test it tomorrow 

require("internal/events")
require("internal/filters")
require("internal/panorama")
require("internal/shortcuts")
require("internal/talents")
require("internal/thinker")
require("internal/xp_modifier")

softRequire("events")
softRequire("filters")
softRequire("settings_butt")
softRequire("settings_misc")
softRequire("startitems")
softRequire("thinker")

function Precache( context )
	FireGameEvent("addon_game_mode_precache",nil)
	PrecacheResource("soundfile", "soundevents/custom_sounds.vsndevts", context)
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
end

function Spawn()
	FireGameEvent("addon_game_mode_spawn",nil)
	local gmE = GameRules:GetGameModeEntity()

	gmE:SetUseDefaultDOTARuneSpawnLogic(true)
	gmE:SetTowerBackdoorProtectionEnabled(true)
	GameRules:SetShowcaseTime(0)

	FireGameEvent("created_game_mode_entity",{gameModeEntity = gmE})
end

function Activate()
	FireGameEvent("addon_game_mode_activate",nil)
	-- GameRules.GameMode = GameMode()
	-- FireGameEvent("init_game_mode",{})
end

ListenToGameEvent("addon_game_mode_activate", function()
	print( "Dota Butt Template is loaded." )
end, nil)
