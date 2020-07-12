-- called from internal/filters

-- Filters allow you to do some code on specific events.
-- Whats special about it: you can manipulate some values here.

Filters = class({})


function Filters:AbilityTuningValueFilter(event)
	-- called on most abilities for each value
	-- PrintTable(event)
	local ability = event.entindex_ability_const and EntIndexToHScript(event.entindex_ability_const)
	local casterUnit = event.entindex_caster_const and EntIndexToHScript(event.entindex_caster_const)
	local valueName = event.value_name_const -- e.g. duration or area_of_affect
	local value = event.value -- can not get modified with local

	-- --  example
		-- event.value = 10

	return true
end

function Filters:BountyRunePickupFilter(event)
	-- PrintTable(event)
	local playerID = event.player_id_const
	local xp = event.xp_bounty -- can not get modified with local
	local gold = event.gold_bounty -- can not get modified with local

	local heroUnit = playerID and PlayerResource:GetSelectedHeroEntity(playerID)

	-- --  example
		-- event.gold_bounty = 10
		-- event.xp_bounty = 10

	return true
end

function Filters:DamageFilter(event)
	-- PrintTable(event)
	local attackerUnit = event.entindex_attacker_const and EntIndexToHScript(event.entindex_attacker_const)
	local victimUnit = event.entindex_victim_const and EntIndexToHScript(event.entindex_victim_const)
	local damageType = event.damagetype_const
	local damage = event.damage -- can not get modified with local

	-- --  example
		-- event.damage = 10

	return true
end

function Filters:ExecuteOrderFilter(event)
	-- PrintTable(event)
	local ability = event.entindex_ability and EntIndexToHScript(event.entindex_ability)
	local targetUnit = event.entindex_target and EntIndexToHScript(event.entindex_target)
	local playerID = event.issuer_player_id_const
	local orderType = event.order_type
	local pos = Vector(event.position_x,event.position_y,event.position_z)
	local queue = event.queue
	local seqNum = event.sequence_number_const
	local units = event.units
	local unit = units and units["0"] and EntIndexToHScript(units["0"])

	-- --  example
		-- if pos._len()<2000 then return false end

	return true
end

function Filters:HealingFilter(event)
	-- PrintTable(event)
	local targetUnit = event.entindex_target_const and EntIndexToHScript(event.entindex_target_const)
	local heal = event.heal -- can not get modified with local

	-- --  example
		-- event.heal = event.heal*RandomInt(0,2)
	
	return true
end

function Filters:ItemAddedToInventoryFilter(event)
	-- PrintTable(event)
	local inventory = event.inventory_parent_entindex_const and EntIndexToHScript(event.inventory_parent_entindex_const)
	local item = event.item_entindex_const and EntIndexToHScript(event.item_entindex_const)
	local itemParent = event.item_parent_entindex_const and EntIndexToHScript(event.item_parent_entindex_const)
	local sugg = event.suggested_slot

	-- --  example
	-- --  dunno
	
	return true
end

function Filters:ModifierGainedFilter(event)
	-- PrintTable(event)
	local name = event.name_const
	local duration = event.duration -- can not get modified with local
	local casterUnit = event.entindex_caster_const and EntIndexToHScript(event.entindex_caster_const)
	local parentUnit = event.entindex_parent_const and EntIndexToHScript(event.entindex_parent_const)

	-- --  example
		-- event.duration = duration*RandomFloat(0,2)
	
	return true
end

function Filters:ModifyExperienceFilter(event)
	-- PrintTable(event)
	local playerID = event.player_id_const
	local reason = event.reason_const
	local xp = event.experience -- can not get modified with local
	local heroUnit = playerID and PlayerResource:GetSelectedHeroEntity(playerID)
	
	-- --  example
		-- event.experience = xp*RandomFloat(0,2)

	return true
end

function Filters:ModifyGoldFilter(event)
	-- PrintTable(event) 
	local playerID = event.player_id_const
	local reason = event.reason_const
	local gold = event.gold -- can not get modified with local
	local reliable = event.reliable -- can not get modified with local
	local heroUnit = playerID and PlayerResource:GetSelectedHeroEntity(playerID)

	-- --  example
		-- event.gold = gold*RandomFloat(0,2)

	return true
end


function Filters:RuneSpawnFilter(event)
	-- PrintTable(event)
	-- maybe deprecated? 
	return true
end

function Filters:TrackingProjectileFilter(event)
	-- PrintTable(event)
	local dodgeable = event.dodgeable
	local ability = event.entindex_ability_const and EntIndexToHScript(event.entindex_ability_const)
	local attackerUnit = event.entindex_source_const and EntIndexToHScript(event.entindex_source_const)
	local targetUnit = event.entindex_target_const and EntIndexToHScript(event.entindex_target_const)
	local expireTime = event.expire_time
	local isAttack = (1==event.is_attack)
	local maxImpactTime = event.max_impact_time
	local moveSpeed = event.move_speed -- can not get modified with local

	-- --  example
		-- event.move_speed = moveSpeed*RandomFloat(0,2)

	return true
end
