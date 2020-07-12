LinkLuaModifier("XPModifier","internal/xp_modifier", LUA_MODIFIER_MOTION_NONE)

ListenToGameEvent("npc_spawned",function(event)
	local npc = EntIndexToHScript(event.entindex)
	if npc and npc.AddNewModifier then
		npc:AddNewModifier(npc, nil, "XPModifier", nil)
	end
end, self)

XPModifier = class({})

function XPModifier:IsHidden() return true end
function XPModifier:AllowIllusionDuplicate() return true end

if (IsClient()) then return end

-----------------------------------------------------------------------------------------

BUTTINGS = BUTTINGS or {}

function XPModifier:GetAttributes() 
	return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function XPModifier:DeclareFunctions() --we want to use these functions in this item
	local funcs = {
		-- MODIFIER_PROPERTY_EXP_RATE_BOOST, -- deprecated
		MODIFIER_PROPERTY_RESPAWNTIME_PERCENTAGE,
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE_STACKING,
		MODIFIER_EVENT_ON_ATTACK_FAIL,
		-- MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_EVENT_ON_TAKEDAMAGE, -- OnTakeDamage 
	--	MODIFIER_EVENT_ON_DEATH, -- seems to be fixed now :)
	}

	return funcs
end

-- function XPModifier:GetModifierPercentageExpRateBoost()
-- 	return BUTTINGS.BONUS_XP_PERCENTAGE
-- end




-- -- fix for > lvl 30 cuz volvo
-- -- seems to be fixed now :)
-- function XPModifier:OnDeath(event)
-- 	local unit = event.unit
-- 	local level = unit and unit.GetLevel and unit:GetLevel()

-- 	if self:GetParent()==unit and level>MAX_LEVEL and IsServer() then
-- 		-- print("#### OnDeath xp_modifier")
-- 		-- PrintTable(event)
-- 		GameRules:GetGameModeEntity():SetThink(function ( ... )
-- 			unit:SetTimeUntilRespawn( level * 4 * BUTTINGS.RESPAWN_TIME_PERCENTAGE * 0.01 )
-- 		end, 0)
-- 	end

-- end



function XPModifier:GetModifierPercentageRespawnTime()
	return 1 - BUTTINGS.RESPAWN_TIME_PERCENTAGE * 0.01
end


function XPModifier:IsPermanent() 
	return true
end

function XPModifier:IsPurgable()
	return false
end


function XPModifier:GetModifierPercentageCooldownStacking()
	return 100 - BUTTINGS.COOLDOWN_PERCENTAGE
end

function XPModifier:OnAttackFail( event )
	if event.attacker ~= self:GetParent() then return end
	if (1==event.fail_type) and (1==BUTTINGS.NO_UPHILL_MISS) then
		event.attacker:PerformAttack(event.target, false, event.process_procs, true, event.ignore_invis, false, false, false)
		event.fail_type = 0
	end
end

-- -- Only run on server so client still shows unmodified armor values
-- if IsServer() then
-- 	function XPModifier:GetModifierPhysicalArmorBonus()
-- 		if (1~=BUTTINGS.CLASSIC_ARMOR) then
-- 			return 0
-- 		end
-- 		local unit = self:GetParent()
-- 		if (self.checkArmor) then
-- 			return 0
-- 		else
-- 			self.checkArmor = true
-- 			self.armor = self:GetParent():GetPhysicalArmorValue(false)
-- 			self.checkArmor = false
-- 			local formula = 45 * self.armor / (52 + 0.2 * math.abs(self.armor)) - self.armor
-- 			print(unit:IsIllusion() and "illu" or "hero", unit:GetName(), self.armor,formula)
-- 			return formula
-- 		end
-- 	end
-- end

-- avoid 100% magic resistance
function XPModifier:OnTakeDamage(event)
	local victim = event.unit
	if self:GetParent()~=victim then return end
	local attacker = event.attacker
	local damageType = event.damage_type
	local damage = event.damage
	local originalDamage = event.original_damage	
	local inflictor = event.inflictor
	local damageFlags = event.damage_flags

	if (1==BUTTINGS.MAGIC_RES_CAP) and (damageType == DAMAGE_TYPE_MAGICAL) and (0 == bit.band(DOTA_DAMAGE_FLAG_IGNORES_MAGIC_ARMOR, damageFlags)) then
		local armor = victim:GetMagicalArmorValue() -- 0 .. 1 .. infinity
		local betterDamageMultiplier = 1 - math.exp( -armor )
		local extraDamage = originalDamage * betterDamageMultiplier - damage

		ApplyDamage({
						victim = victim,
						attacker = attacker,
						damage = extraDamage,
						damage_type = DAMAGE_TYPE_MAGICAL,
						damage_flags = DOTA_DAMAGE_FLAG_IGNORES_MAGIC_ARMOR, -- Optional, more can be added with + .. No flags = 0.
						ability = inflictor	-- Optional, but we have an ability here (=self)
					}) -- deal damage
	end

	if (1==BUTTINGS.CLASSIC_ARMOR) and (damageType == DAMAGE_TYPE_PHYSICAL) and (0 == bit.band(DOTA_DAMAGE_FLAG_IGNORES_PHYSICAL_ARMOR, damageFlags)) then
		local armor = victim:GetPhysicalArmorValue(false)
		local betterDamageMultiplier = 1 - ( 0.05 * armor ) / ( 1 + 0.05 * armor )
		local extraDamage = originalDamage * betterDamageMultiplier - damage

		ApplyDamage({
						victim = victim,
						attacker = attacker,
						damage = extraDamage,
						damage_type = DAMAGE_TYPE_PHYSICAL,
						damage_flags = DOTA_DAMAGE_FLAG_IGNORES_PHYSICAL_ARMOR, -- Optional, more can be added with + .. No flags = 0.
						ability = inflictor	-- Optional, but we have an ability here (=self)
					}) -- deal damage
	end
end

function XPModifier:CheckState()
	return {
		-- [MODIFIER_STATE_CANNOT_MISS] =  false,
		-- [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY ] =  false,
	}
end