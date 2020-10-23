print("[ Loading Schokokeks courier fix ]")
require("internal/utils/butt_api")
BUTTINGS = BUTTINGS or {}

-- LinkLuaModifier("modifier_courier_fix", "utils/courier", LUA_MODIFIER_MOTION_NONE)

_G.personalCouriers = _G.personalCouriers or {}
_G.mainTeamCouriers = _G.mainTeamCouriers or {}

LinkLuaModifier("modifier_courier", "internal/modifier_courier.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_passive_gold", "internal/modifier_passive_gold.lua", LUA_MODIFIER_MOTION_NONE)


ListenToGameEvent("npc_first_spawn",function(event)
	local hero = EntIndexToHScript(event.entindex)
	if (not hero:IsRealHero()) then return end
	-- don't give passive gold to monkey king clones
	Timers:CreateTimer(0, function()
		if not IsMonkeyKingClone(hero) then
			hero:AddNewModifier(hero,nil,"modifier_passive_gold",{ gold_per_tick = 1, gold_tick_time = (60/BUTTINGS.GOLD_PER_MINUTE) })
		end
	end)
end, self)

function CreatePrivateCourier(playerId, owner, pointToSpawn)
	if personalCouriers[playerId] then return end
	local courier_spawn = pointToSpawn -- + RandomVector(RandomFloat(100, 100))
	
	local team = owner:GetTeamNumber()
	
	local cr = CreateUnitByName("npc_dota_courier", courier_spawn, true, nil, nil, team)
	-- cr:SetOwner(owner) -- binds passive gold
	-- cr:AddNewModifier(cr, nil, "modifier_patreon_courier", {})
	Timers:CreateTimer(0.1, function()
		cr:SetControllableByPlayer(playerId, true)
		_G.personalCouriers[playerId] = cr;
	end)
	return cr
end

function EditFilterToCourier(filterTable)
	if 1~=BUTTINGS.FREE_COURIER then return end
	local unit
	local orderType = filterTable.order_type
	local target = filterTable.entindex_target ~= 0 and EntIndexToHScript(filterTable.entindex_target) or nil
	local ability = filterTable.entindex_ability ~= 0 and EntIndexToHScript(filterTable.entindex_ability) or nil
	local playerId = filterTable.issuer_player_id_const

	if playerId < 0 then return filterTable end
	if not PlayerResource:GetPlayer(playerId):GetAssignedHero() then return filterTable end

	local hasCourierInUnitsTable = false
	for _, unitEntityIndex in pairs(filterTable.units) do
		unit = EntIndexToHScript(unitEntityIndex)
		if unit:IsCourier() then hasCourierInUnitsTable = true end
	end
	if not hasCourierInUnitsTable then return filterTable end

	local currentCourier = SearchCorrectCourier(playerId, PlayerResource:GetPlayer(playerId):GetAssignedHero():GetTeamNumber())

	if orderType == DOTA_UNIT_ORDER_GIVE_ITEM and target and target:IsCourier() and target ~= currentCourier and currentCourier:IsAlive() and (not currentCourier:IsStunned()) then
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerId), "display_custom_error", { message = "#cannotgiveiteminthiscourier" })
		return false
	end

	for _, unitEntityIndex in pairs(filterTable.units) do
		unit = EntIndexToHScript(unitEntityIndex)

		if unit:IsCourier() then
			for i, x in pairs(filterTable.units) do
				if filterTable.units[i] == unitEntityIndex then
					if currentCourier then
						filterTable.units[i] = currentCourier:GetEntityIndex()
					end
				end
			end

			if  currentCourier and unit ~= currentCourier and currentCourier:IsAlive() and (not currentCourier:IsStunned()) then
				for i = 0, 20 do
					if filterTable.entindex_ability and currentCourier:GetAbilityByIndex(i) and ability and currentCourier:GetAbilityByIndex(i):GetName() == ability:GetName() then
						filterTable.entindex_ability = currentCourier:GetAbilityByIndex(i):GetEntityIndex()
					end
				end

				local newFocus = { currentCourier:GetEntityIndex() }
				CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerId), "selection_courier_update", { newCourier = newFocus, removeCourier = { unitEntityIndex } })
			end
		end
	end

	return filterTable
end

function BlockToBuyCourier(playerId, hItem)
	if _G.personalCouriers[playerId] then
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerId), "display_custom_error", { message = "#alreadyhaveprivatecourier" })
	else
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerId), "display_custom_error", { message = "#nopatreonerror2" })
	end
	UTIL_Remove(hItem)
end

function SearchCorrectCourier(playerID, team)
	local currentCourier
	local psets = { level = 0 }
	if _G.personalCouriers[playerID] and _G.personalCouriers[playerID]:IsAlive() and (not _G.personalCouriers[playerID]:IsStunned()) then
		currentCourier = _G.personalCouriers[playerID]
	elseif _G.mainTeamCouriers[team] and _G.mainTeamCouriers[team]:IsAlive() and (not _G.mainTeamCouriers[team]:IsStunned()) then
		currentCourier = _G.mainTeamCouriers[team]
	else
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "display_custom_error", { message = "#allcouriersdie" })
	end

	return currentCourier
end

CustomGameEventManager:RegisterListener("courier_custom_select", function(_,data)
	local playerID = data.PlayerID
	if not playerID then return end

	local player = PlayerResource:GetPlayer(playerID)
	local team = player:GetTeamNumber()
	local currentCourier = SearchCorrectCourier(playerID, team)

	if currentCourier then
		CustomGameEventManager:Send_ServerToPlayer(player, "selection_new", { entities = { currentCourier:GetEntityIndex() } })
	end
end)

function unitMoveToPoint(unit, point)
	ExecuteOrderFromTable({
		UnitIndex = unit:entindex(),
		OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
		Position = point
	})
end

CustomGameEventManager:RegisterListener("courier_custom_select_deliever_items", function(_,data)
	local playerID = data.PlayerID
	if not playerID then return end
	local player = PlayerResource:GetPlayer(playerID)
	local team = player:GetTeamNumber()
	local currentCourier = SearchCorrectCourier(playerID, team)

	if currentCourier then
		local stashHasItems = false
		for i = 10, 15 do
			local item = player:GetAssignedHero():GetItemInSlot(i)
			if item ~= nil then
				stashHasItems = true
			end
		end

		if stashHasItems then
			currentCourier:CastAbilityNoTarget(currentCourier:GetAbilityByIndex(7), playerID)
		else
			unitMoveToPoint(currentCourier, player:GetAssignedHero():GetAbsOrigin())
			currentCourier:CastAbilityNoTarget(currentCourier:GetAbilityByIndex(4), playerID)
		end
	end
end)
