BUTTINGS = BUTTINGS or {MAX_LEVEL = MAX_LEVEL}

require("internal/utils/butt_api")
LinkLuaModifier("modifier_courier_speed", "internal/modifier_courier_speed.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("backdoor_protection_imba", "internal/backdoor_protection_imba.lua", LUA_MODIFIER_MOTION_NONE)

function get_random_key(t)
    local ti = {}
    for k,v in pairs(t) do
		if v ~= nil then
        	table.insert(ti,k)
		end
    end
    return ti[RandomInt(1, #ti)]
end
ListenToGameEvent("game_rules_state_change", function()
	if (GameRules:State_Get()==DOTA_GAMERULES_STATE_HERO_SELECTION) then
		
		GameRules:SetSameHeroSelectionEnabled( 1 == Buttings:GetQuick("ALLOW_SAME_HERO_SELECTION"))
		GameRules:SetUseUniversalShopMode( 1 == Buttings:GetQuick("UNIVERSAL_SHOP_MODE") )
		GameRules:SetGoldTickTime( 60/Buttings:GetQuick("GOLD_PER_MINUTE")  )

		GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel( BUTTINGS.ALTERNATIVE_XP_TABLE() )
		GameRules:GetGameModeEntity():SetUseCustomHeroLevels(Buttings:GetQuick("MAX_LEVEL") ~=30)
		GameRules:SetUseCustomHeroXPValues(Buttings:GetQuick("MAX_LEVEL") ~=30)
		GameRules:GetGameModeEntity():SetCustomHeroMaxLevel(Buttings:GetQuick("MAX_LEVEL") )

		if ("AR"==Buttings:GetQuick("GAME_MODE") ) then
			local time = ( 1 == Buttings:GetQuick("HERO_BANNING")  ) and 16 or 0
			GameRules:GetGameModeEntity():SetThink( function()
				for p,player in pairs(PlayerList:GetValidTeamPlayers()) do
					player:MakeRandomHeroSelection()
				end
			end, time)
		end


		if ("SD"==Buttings:GetQuick("GAME_MODE") ) then
			GameRules:GetGameModeEntity():SetDraftingBanningTimeOverride( 0 )
			local attribute_heroes = {
				{},		-- strength_heroes
				{},		-- agility_heroes
				{}		-- intelligence_heroes
			}
			local file = LoadKeyValues('scripts/npc/herolist.txt')
			local hero_definitions = LoadKeyValues('scripts/npc/npc_heroes.txt')
			if file == nil or not next(file) then
				print("empty whitelist")
			else
				for hero_name, _ in pairs(file) do
					local hero_attribute = hero_definitions[hero_name]["AttributePrimary"]
					if hero_attribute == "DOTA_ATTRIBUTE_STRENGTH" then
						table.insert(attribute_heroes[1], hero_name)
					elseif hero_attribute == "DOTA_ATTRIBUTE_AGILITY" then
						table.insert(attribute_heroes[2], hero_name)
					else
						table.insert(attribute_heroes[3], hero_name)
					end
				end

				GameRules:SetHideBlacklistedHeroes(true)
				GameRules:GetGameModeEntity():SetPlayerHeroAvailabilityFiltered( true )
				for p=0,DOTA_MAX_PLAYERS do
					if PlayerResource:IsValidPlayer(p) then
						for i=1,3 do
							local hero_index = get_random_key(attribute_heroes[i])
							local nHeroID = DOTAGameManager:GetHeroIDByName( attribute_heroes[i][hero_index] )
							GameRules:AddHeroToPlayerAvailability( p, nHeroID )
							attribute_heroes[i][hero_index] = nil
						end
					end
				end
			end

		else
			if ( 0 == Buttings:GetQuick("HERO_BANNING") ) then
				GameRules:GetGameModeEntity():SetDraftingBanningTimeOverride( 0 )
			else
				GameRules:GetGameModeEntity():SetDraftingBanningTimeOverride( 16 )
			end
		end

		if ( 1 == Buttings:GetQuick("SIDE_SHOP")  ) then
			for _,pos in pairs(Butt:OldSideshopLocations()) do
				Butt:CreateSideShop(pos)
			end
		end
		if ( 1 == Buttings:GetQuick("OUTPOST_SHOP")  ) then
			for o,outpost in pairs(Butt:AllOutposts()) do
				Butt:CreateSideShop(outpost:GetAbsOrigin())
			end
		end

		if ( "NORM" ~= Buttings:GetQuick("BACKDOOR_PROTECTION")  ) then
			for _, building in pairs(Butt:AllBuildings()) do
				if ( "NONE" == Buttings:GetQuick("BACKDOOR_PROTECTION")  ) then
					building:RemoveAbility("backdoor_protection")
					building:RemoveAbility("backdoor_protection_in_base")
				end

				if ( "IMBA" == Buttings:GetQuick("BACKDOOR_PROTECTION")  ) then
					building:AddNewModifier(building, nil, "backdoor_protection_imba", {})
				end
			end
		end

		GameRules:GetGameModeEntity():SetFreeCourierModeEnabled(true)
	end

	-- Bot Usage Logic - Courtesy of DrTeaSpoon
	if (GameRules:State_Get()==DOTA_GAMERULES_STATE_STRATEGY_TIME) then
        local num = 0
        local used_hero_name = "npc_dota_hero_luna"
        local heroes_used = {}

        for i=0, DOTA_MAX_TEAM_PLAYERS do
            if PlayerResource:IsValidPlayer(i) then
                local player = PlayerResource:GetPlayer(i)
                if PlayerResource:HasSelectedHero(i) == false then
                    player:MakeRandomHeroSelection()
                end
                used_hero_name = PlayerResource:GetSelectedHeroName(i)
                num = num + 1
            end
        end
        if Buttings:GetQuick("USE_BOTS")  == 1 then
            if IsServer() == true and 10 - num > 0 then
                for i=1, 5 - PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS) do
                    Tutorial:AddBot(used_hero_name, "", "", true)
                end
				for i=1,5 - PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_BADGUYS) do
					Tutorial:AddBot(used_hero_name, "", "", false)
				end
                GameRules:GetGameModeEntity():SetBotThinkingEnabled(true)
                SendToServerConsole("dota_bot_set_difficulty 4")
                SendToConsole("dota_bot_set_difficulty 4")
                SendToServerConsole("dota_bot_populate")
                SendToServerConsole("dota_bot_mode 1")
                SendToServerConsole("dota_bot_takeover_disconnected 1")
                SendToServerConsole("dota_bot_match_difficulty 4")
                SendToServerConsole("dota_bot_use_machine_learned_weights 1")
            end
        end
    end

	-- Remove the shard from the shop so I can re-add it with the timer later
	if (GameRules:State_Get()==DOTA_GAMERULES_STATE_PRE_GAME) then
		Timers:CreateTimer({
			endTime = FrameTime(),
			callback = function()
				for _,p in pairs(PlayerList:GetFirstPlayers()) do
					local pID = p:GetPlayerID()
					GameRules:SetItemStockCount( 0, PlayerResource:GetTeam( pID ), "item_aghanims_shard", pID )
				end
			end
		})
	end

	if (GameRules:State_Get()==DOTA_GAMERULES_STATE_GAME_IN_PROGRESS) then
		GameRules:SetTimeOfDay( 0.251 )
		Timers:CreateTimer({
			endTime = Buttings:GetQuick("TIME_UNTIL_AGH_SHARD") *60,
			callback = function()
				if (0 == Buttings:GetQuick("FREE_AGH_SHARD") ) then
					for _,p in pairs(PlayerList:GetFirstPlayers()) do
						local pID = p:GetPlayerID()

						GameRules:SetItemStockCount( 
							PlayerResource:GetPlayerCountForTeam(PlayerResource:GetTeam( pID )), 
							PlayerResource:GetTeam( pID ), 
							"item_aghanims_shard", 
							pID 
						)
					end
				else
					for _,p in pairs(PlayerList:GetValidTeamPlayers()) do
						local hero = PlayerResource:GetSelectedHeroEntity(p:GetPlayerID())
						hero:AddNewModifier(hero, nil, "modifier_item_aghanims_shard", {})
					end
				end
			end

		})
	end

	CustomGameEventManager:Send_ServerToAllClients("scoreboard_fix", {radiantKills = GetTeamHeroKills(DOTA_TEAM_GOODGUYS), direKills = GetTeamHeroKills(DOTA_TEAM_BADGUYS)})
end, nil)

ListenToGameEvent("npc_spawned", function(keys)
	local unit = keys.entindex and EntIndexToHScript(keys.entindex)

	if unit then
		if unit:GetClassname() == "npc_dota_watch_tower" then       --- BugFix by RoboBro
			Timers:CreateTimer(
				1, 
				function() unit:RemoveModifierByName("modifier_invulnerable") end
			)
		
		elseif unit:IsCourier() then 
			unit:AddNewModifier(unit, nil, "modifier_courier_speed", {})
		end
	end

end, nil)

ListenToGameEvent("dota_player_pick_hero", function(keys)
end, self)

ListenToGameEvent("dota_player_killed",function(kv)
	if (1==Buttings:GetQuick("ALT_WINNING") ) then
		-- local unit = PlayerResource:GetSelectedHeroEntity(kv.PlayerID)
		for _,t in ipairs(TeamList:GetPlayableTeams()) do
			if (PlayerResource:GetTeamKills(t)>=Buttings:GetQuick("ALT_KILL_LIMIT") ) then
				GameRules:SetGameWinner(t)
			end
		end
end
end, nil)

ListenToGameEvent("entity_killed", function(keys)
	local killedUnit = EntIndexToHScript(keys.entindex_killed)
	if killedUnit:IsRealHero() and not killedUnit:IsTempestDouble() and not killedUnit:IsReincarnating() then

		-- tombstone
		if (1==Buttings:GetQuick("TOMBSTONE") ) then
			local tombstoneItem = CreateItem("item_tombstone", killedUnit, killedUnit)
			if (tombstoneItem) then
				local tombstone = SpawnEntityFromTableSynchronous("dota_item_tombstone_drop", {})
				tombstone:SetContainedItem(tombstoneItem)
				tombstone:SetAngles(0, RandomFloat(0, 360), 0)
				FindClearSpaceForUnit(tombstone, killedUnit:GetAbsOrigin(), true)
			end
		end

	end
	
	-- Scoreboard Fix
	CustomGameEventManager:Send_ServerToAllClients("scoreboard_fix", {radiantKills = GetTeamHeroKills(DOTA_TEAM_GOODGUYS), direKills = GetTeamHeroKills(DOTA_TEAM_BADGUYS)})
end, nil)
