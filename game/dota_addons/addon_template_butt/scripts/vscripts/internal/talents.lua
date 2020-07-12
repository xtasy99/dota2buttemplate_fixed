ListenToGameEvent("dota_player_learned_ability",function(keys)
	local player = EntIndexToHScript(keys.player)
	local abilityname = keys.abilityname

	if (abilityname:find("special_bonus_") == 1) then
		local hero = player:GetAssignedHero()
		local ability = hero:FindAbilityByName(abilityname)
		local modifiername = "modifier_" .. abilityname
		local file = "talents/"..modifiername
		if pcall(require,file) then
			LinkLuaModifier(modifiername, file, LUA_MODIFIER_MOTION_NONE)
			hero:AddNewModifier(hero, ability, modifiername, {})
		end
	end
	
end, self)