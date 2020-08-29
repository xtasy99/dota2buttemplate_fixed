require("internal/utils/butt_api")

local startitems = {
	-- item_patreon_7 = {},
	-- item_shivas_guard = { amt = 2, cast = true, cd = 10 },
	-- item_travel_boots = {amt=20, cd= 100},
}
local bonusabilities = {
	-- exampleability = { lvl = 1, cd = 120 , nokey = true, hidden = true, cast = true },
	-- roshan_spell_block = { lvl = 4, nokey = true },
}
local bonusmodifier = {
	examplemodifier = {duration = 5},
	-- examplemodifier = {},
}
local talents = {
	[8] = "",	[7] = "",
	[6] = "",	[5] = "",
	[4] = "",	[3] = "",
	[2] = "",	[1] = "",
	-- [2] = "",	[1] = "special_bonus_exampletalent",
}

ListenToGameEvent("npc_first_spawn",function(kv)
	local hero = EntIndexToHScript(kv.entindex)


	if (not hero:IsHero()) then return end

	-- Abilities

	for abil,kv in pairs(bonusabilities) do
		if (not kv.nokey) then hero:RemoveAbility("generic_hidden") end
		local a = hero:AddAbility(abil)
		a:SetLevel(kv.level or kv.lvl or 0)
		if (kv.cast) then a:CastAbility() end
		a:SetHidden(kv.hidden or false)
		a:StartCooldown(kv.cooldown or kv.cd or 0)
	end

	if (not hero:IsRealHero()) then return end

	
	-- Items

	Timers:CreateTimer(0.5, function ()
		for item,data in pairs(startitems) do
			local amt = data.amt or data.amount or 1
			for i=1,amt do
				local newitem = hero:AddItemByName(item)
				if (data.cast) then newitem:CastAbility() end
				if (data.cd) then newitem:StartCooldown(data.cd) end
			end
		end
		return nil
	end)

	-- Modifiers

	for name,data in pairs(bonusmodifier) do
		hero:AddNewModifierButt(hero, nil, name, data)
	end

	-- Talents

	local heroTalents = hero:GetAllTalents() -- with abilitynumber
	
	local ind = {}
	for i,_ in pairs(heroTalents) do
		table.insert(ind,i)
	end

	for i,name in pairs(talents) do
		if (name~="") and (not hero:FindAbilityByName(name)) then
			local pos = ind[i]
			hero:RemoveAbility(heroTalents[pos]:GetName())
			hero:AddAbility(name):SetAbilityIndex(pos)
		end
	end

end, self)
