ListenToGameEvent("created_game_mode_entity",function()
	local gameModeEnt = GameRules:GetGameModeEntity()
	
	GameRules:SetFirstBloodActive( true )						-- Sets whether First Blood should give bonus gold. 
	GameRules:SetHeroRespawnEnabled( true )						-- Control if the normal DOTA hero respawn rules apply. 
	GameRules:SetHeroSelectionTime( 110 )						-- Sets the amount of time players have to pick their hero. 
	GameRules:SetStrategyTime( 10 ) 					-- Sets the amount of time players have between the hero selection and entering the showcase phase. 
	GameRules:SetHideKillMessageHeaders( false )				-- Sets whether or not the kill banners should be hidden 
	GameRules:SetPostGameTime( 180 )							-- Sets the amount of time players have between the game ending and the server disconnecting them. 
	GameRules:SetPreGameTime( 90 )								-- Sets the amount of time players have between picking their hero and game start. 
	GameRules:SetRuneSpawnTime( 120 )							-- Sets the amount of time between rune spawns. 
	GameRules:SetTreeRegrowTime( 300 )							-- Sets the tree regrow time in seconds. 
	GameRules:SetUseBaseGoldBountyOnHeroes( false )				

	gameModeEnt:SetAlwaysShowPlayerInventory( false )			-- Show the player hero's inventory in the HUD, regardless of what unit is selected. 
	gameModeEnt:SetAnnouncerDisabled( false )					-- Disables the dota announcer 
	gameModeEnt:SetBotsAlwaysPushWithHuman( false )				-- Set if the bots should try their best to push with a human player. 
	gameModeEnt:SetBotsInLateGame( false )						-- Bots behave different in late game
	gameModeEnt:SetBotsMaxPushTier( -1 )						-- Set the max tier of tower that bots want to push. (-1 to disable) 
	gameModeEnt:SetBotThinkingEnabled( false )					-- Enables/Disables bot thinking. Requires a very Dota PvP-like map with 3 lanes, a shop, etc. 
	gameModeEnt:SetBuybackEnabled( true )						-- Enables or disables buyback completely 
	gameModeEnt:SetCameraDistanceOverride( 1134 )				-- Set a different camera distance; dota default is 1134. 
	gameModeEnt:SetCustomBuybackCooldownEnabled( false )		-- Turns on capability to define custom buyback cooldowns. 
	gameModeEnt:SetCustomBuybackCostEnabled( false )			-- Turns on capability to define custom buyback costs. 
	gameModeEnt:SetFixedRespawnTime( -1 ) 						-- Sets the dota respawn time. -1 for default behavior 
	gameModeEnt:SetFogOfWarDisabled( false )					-- Turn the fog of war on or off. 
	gameModeEnt:SetFountainConstantManaRegen( -1 )				-- Set the constant rate that the fountain will regen mana. (-1 for default) 
	gameModeEnt:SetFountainPercentageHealthRegen( -1 )			-- Set the percentage rate that the fountain will regen health. (-1 for default) 
	gameModeEnt:SetFountainPercentageManaRegen( -1 )			-- Set the percentage rate that the fountain will regen mana. (-1 for default) 
	gameModeEnt:SetGoldSoundDisabled( false )					-- Turn the sound when gold is acquired off/on.
	gameModeEnt:SetLoseGoldOnDeath( true )						-- Use to disable gold loss on death. 
	gameModeEnt:SetMaximumAttackSpeed( 700 )					-- Set the maximum attack speed for units. 
	gameModeEnt:SetMinimumAttackSpeed( 20 )						-- Set the minimum attack speed for units. 
	gameModeEnt:SetPauseEnabled( true )							-- Allow/Disallow players to pause the game. 
	gameModeEnt:SetRecommendedItemsDisabled( false )			-- Turn the panel for showing recommended items at the shop off/on.
	gameModeEnt:SetRemoveIllusionsOnDeath( false )				-- Make it so illusions are immediately removed upon death, rather than sticking around for a few seconds. 
	gameModeEnt:SetStashPurchasingDisabled( false )				-- Turn purchasing items to the stash off/on. If purchasing to the stash is off the player must be at a shop to purchase items. 
	gameModeEnt:SetTopBarTeamValuesVisible( true )				-- Turning on/off the team values on the top game bar. 
	gameModeEnt:SetTowerBackdoorProtectionEnabled( true )		-- Enables/Disables tower backdoor protection 
	gameModeEnt:SetUnseenFogOfWarEnabled( false )				-- black starting map


	if false then -- set true to use custom rules
		gameModeEnt:SetUseDefaultDOTARuneSpawnLogic(false)		-- true = river runes spawn at 2:00, all runes. false = required to disable runes, they start at 0:00
		gameModeEnt:SetRuneEnabled(DOTA_RUNE_DOUBLEDAMAGE, true)
		gameModeEnt:SetRuneEnabled(DOTA_RUNE_HASTE, true)
		gameModeEnt:SetRuneEnabled(DOTA_RUNE_ILLUSION, true)
		gameModeEnt:SetRuneEnabled(DOTA_RUNE_INVISIBILITY, true)
		-- this is broken, therefore always true: gameModeEnt:SetRuneEnabled(DOTA_RUNE_REGENERATION, true)
	end

	if false then -- set true to use custom colors
		SetTeamCustomHealthbarColor(DOTA_TEAM_GOODGUYS, 61, 210, 150 )	--	Teal
		SetTeamCustomHealthbarColor(DOTA_TEAM_BADGUYS, 243, 201, 9 )	--	Yellow
		SetTeamCustomHealthbarColor(DOTA_TEAM_CUSTOM_1, 197, 77, 168 )	--	Pink
		SetTeamCustomHealthbarColor(DOTA_TEAM_CUSTOM_2, 255, 108, 0 )	--	Orange
		SetTeamCustomHealthbarColor(DOTA_TEAM_CUSTOM_3, 52, 85, 255 )	--	Blue
		SetTeamCustomHealthbarColor(DOTA_TEAM_CUSTOM_4, 101, 212, 19 )	--	Green
		SetTeamCustomHealthbarColor(DOTA_TEAM_CUSTOM_5, 129, 83, 54 )	--	Brown
		SetTeamCustomHealthbarColor(DOTA_TEAM_CUSTOM_6, 27, 192, 216 )	--	Cyan
		SetTeamCustomHealthbarColor(DOTA_TEAM_CUSTOM_7, 199, 228, 13 )	--	Olive
		SetTeamCustomHealthbarColor(DOTA_TEAM_CUSTOM_8, 140, 42, 244 )	--	Purple
	end
end, nil)
