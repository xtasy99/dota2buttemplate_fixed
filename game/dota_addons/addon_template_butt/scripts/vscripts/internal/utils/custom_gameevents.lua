local spawnedNPCs = {}
ListenToGameEvent("npc_spawned", function(keys)
	-- entindex numbers repeat after a while 
	local npc = EntIndexToHScript(keys.entindex)
	if (spawnedNPCs[keys.entindex] ~= npc) then
		spawnedNPCs[keys.entindex] = npc
		FireGameEvent("npc_first_spawn", {entindex = keys.entindex, unit = npc})
	end
end, nil)

-- local l1 = 0
-- local l2 = 0
-- local function fireGME()
-- 	local gME = GameRules:GetGameModeEntity()
-- 	if (gME) then 									-- comes with the first Buildings
-- 		FireGameEvent("created_game_mode_entity", {gameModeEntity = gME})
-- 		StopListeningToGameEvent(l1)
-- 		StopListeningToGameEvent(l2)
-- 	end
-- end
-- l1 = ListenToGameEvent("npc_spawned", fireGME, nil)
-- l2 = ListenToGameEvent("game_rules_state_change", fireGME, nil) -- backup


ListenToGameEvent("game_rules_state_change", function()
	if (GameRules:State_Get()==DOTA_GAMERULES_STATE_GAME_IN_PROGRESS) then
		FireGameEvent("game_rules_state_game_in_progress", {})
	end
end, nil)
