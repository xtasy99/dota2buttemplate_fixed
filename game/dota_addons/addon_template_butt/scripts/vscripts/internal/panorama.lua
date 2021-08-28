BUTTINGS = BUTTINGS or {}

local PATHS = {
	default = {
		abilities = ADDON_FOLDER .. "../../dota/scripts/npc/npc_abilities.txt",
		heroes = ADDON_FOLDER .. "../../dota/scripts/npc/npc_heroes.txt",
		items = ADDON_FOLDER .. "scripts/npc/items.txt",
		neutralItems = ADDON_FOLDER .. "scripts/npc/neutral_items.txt",
		units = ADDON_FOLDER .. "../../dota/scripts/npc/npc_units.txt"
	},
	custom = {
		abilities = ADDON_FOLDER .. "scripts/npc/npc_abilities_custom.txt",
		heroes = ADDON_FOLDER .. "scripts/npc/npc_heroes_custom.txt",
		items = ADDON_FOLDER .. "scripts/npc/npc_items_custom.txt",
		neutralItems = ADDON_FOLDER .. "scripts/npc/npc_neutral_items_custom.txt",
		units = ADDON_FOLDER .. "scripts/npc/npc_units_custom.txt"
	}
}
local TABLE_NAMES = {
		abilities = "DOTAAbilities",
		heroes = "DOTAHeroes",
		items = "DOTAAbilities",
		neutralItems = "neutral_items",
		units = "DOTAUnits",
}


ListenToGameEvent("addon_game_mode_spawn", function()
	CustomNetTables:SetTableValue("butt_settings", "default", BUTTINGS)
end, nil)

local l0 = CustomGameEventManager:RegisterListener("butt_setting_changed", function(_,kv)
	BUTTINGS[kv.setting] = kv.value
	print(kv.setting,":",kv.value)
end)

local l1 =ListenToGameEvent("game_rules_state_change", function()
	if (GameRules:State_Get()==DOTA_GAMERULES_STATE_HERO_SELECTION) then
		CustomNetTables:SetTableValue("butt_settings", "locked", BUTTINGS)
	end
end, nil)

local l2 = CustomGameEventManager:RegisterListener("butt_on_clicked", function(_,kv)
	local name = kv.button
	if ("RESET"==name) then
		-- BUTTINGS = table.copy(BUTTINGS_DEFAULT)
		for k,v in pairs(BUTTINGS_DEFAULT) do
			CustomGameEventManager:Send_ServerToAllClients("butt_setting_changed", {setting = k, value = v})
		end
	end
end)

if IsInToolsMode() then -- Item Editor
	local kvs = {}
	function loadKVs()
		kvs = {custom = {}, default= {}}
		for typ,path in pairs(PATHS.default) do kvs.default[typ] = fileToTable(path) or {} end
		for typ,path in pairs(PATHS.custom)  do kvs.custom[typ]  = fileToTable(path) or {} end
	end
	loadKVs()
	function saveKVs(typ)
		kvs.custom[typ] = kvs.custom[typ] or {}
		if (kvs.custom) and (TABLE_NAMES[typ]) then
			kvToFile({[TABLE_NAMES[typ]] = kvs.custom[typ]}, PATHS.custom[typ])
		end
		return true
	end


	local l1 = CustomGameEventManager:RegisterListener("kv_change", function(_,kv)
		if ("neutralItems"==kv.filter.type) then
			print("kv_change")
			PrintTable(kv)
			for grp,val in pairs(kv.value.neutralItems) do
				if val.items then
					for item,val in pairs(val.items) do
						kvs.custom.items[item] = kvs.custom.items[item] or {}
						kvs.custom.items[item].ItemIsNeutralDrop = ("table"==type(val)) and nil or val
					end
				end
			end
			table.merge(kvs.custom.items,kvs.custom.items)
			saveKVs("items")
		end
		table.merge(kvs.custom,kv.value)
		saveKVs(kv.filter.type)
		loadKVs()
		local data = kv.filter
		data.PlayerID = kv.PlayerID
		handleKvFind("",data)
	end)


	function handleKvFind(_,kv)
		local issuer = PlayerResource:GetPlayer(kv.PlayerID)
		local typ = kv.type
		local result = {default={},custom={}}
		for defCus,_ in pairs(result) do
			if ("table"==type(kvs[defCus][typ])) then for k,v in pairs(kvs[defCus][typ]) do
				if (k:find(kv.name)) then
					result.default[k] = kvs.default[typ][k]
					result.custom[k] = kvs.custom[typ][k]
					if (kv.name:len()<3) then
						CustomGameEventManager:Send_ServerToPlayer(issuer,"kv_result", result)
						return
					end
				end
			end end
		end
		CustomGameEventManager:Send_ServerToPlayer(issuer,"kv_result", result)
	end

	local l3 = CustomGameEventManager:RegisterListener("kv_find", handleKvFind)
end



---------------------------------------------------------------------------------

CustomGameEventManager:RegisterListener("endscreen_butt", function(_,request)
	local playerInfo = {}
	print("endscreen_butt requested")
	for k,v in pairs(request) do
		print("req",k,v,type(k))
		local pID = tonumber(k)
		if pID then
			-- print(pID,v.team)
			playerInfo[pID] = { team = v.team }
			playerInfo[pID].Kills = PlayerResource:GetKills(pID).." ("..PlayerResource:GetStreak(pID)..")"
			playerInfo[pID].Damage = PlayerResource:GetRawPlayerDamage(pID)
			playerInfo[pID].Healing = PlayerResource:GetHealing(pID)
			playerInfo[pID].LH = PlayerResource:GetLastHits(pID).." ("..PlayerResource:GetLastHitStreak(pID)..")"
			playerInfo[pID].GPM = math.floor(PlayerResource:GetGoldPerMin(pID)+0.5)
			playerInfo[pID].EPM = math.floor(PlayerResource:GetXPPerMin(pID)+0.5)
			playerInfo[pID].TotalXP = PlayerResource:GetTotalEarnedXP(pID)
			playerInfo[pID].DamageTaken = PlayerResource:GetCreepDamageTaken(pID, true) + PlayerResource:GetHeroDamageTaken(pID, true) + PlayerResource:GetTowerDamageTaken(pID, true)
			playerInfo[pID].GetGoldSpentOnItems = PlayerResource:GetGoldSpentOnItems(pID)
			playerInfo[pID].RunePickups = PlayerResource:GetRunePickups(pID)
		end
	end
	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(request.PlayerID),"endscreen_butt",playerInfo)
end)