--[[ Legacy Code
if IsInToolsMode() then
	function IsSchokokeks()
		return tostring(PlayerResource:GetSteamID(0))=="76561198007073158"
	end

	ListenToGameEvent("addon_game_mode_activate",function()
		GameRules:GetGameModeEntity():SetThink(function()
			if IsSchokokeks() then -- just works in addon_template_butt folder
				local dotaFolder = ADDON_FOLDER:sub(0,-38)
				-- pcall(copyFile, dotaFolder.."content/dota/maps/dota.vmap", dotaFolder .. "content/dota_addons/addon_template_butt/maps/dota.vmap")
				return
			end
			local agmStr = fileToString(ADDON_FOLDER .. "scripts/vscripts/addon_game_mode.lua")
			if agmStr then
				local repl = " -- generated from Template\n" .. agmStr:gsub("require%(\"internal/init\"%)","-- require%(\"internal/init\"%)")
				strToFile(repl, ADDON_FOLDER .. "scripts/vscripts/addon_game_mode.lua")
			end
		end, 1)
	end, GameRules.GameMode)



	local addInf = LoadKeyValues("addoninfo.txt")
	if not addInf.maps then	addInf.maps = "dota" end
	kvToFile({AddonInfo = addInf}, ADDON_FOLDER .. "addoninfo.txt")

	-- copyFile("../../dota/scripts/npc/npc_units.txt", ADDON_FOLDER .. "scripts/npc/units.txt")
	-- copyFile("../../dota/scripts/npc/npc_abilities.txt", ADDON_FOLDER .. "scripts/npc/abilities.txt")
	-- copyFile("../../dota/scripts/npc/npc_heroes.txt", ADDON_FOLDER .. "scripts/npc/heroes.txt")
	-- print(fileToString("http://github.com/SteamDatabase/GameTracking-Dota2/blob/master/game/dota/pak01_dir/scripts/npc/items.txt"))

end
]]