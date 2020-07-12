exampleability = class({})

function exampleability:OnSpellStart()
	--this is where the ability actually happens

	--reading the values from the kv file
	local radius = self:GetSpecialValueFor( "damage_radius" )
	local dmg = self:GetSpecialValueFor( "self_damage" )
	local dur = self:GetSpecialValueFor("duration")
	local initls = self:GetSpecialValueFor("ls_start")

	-- when we start the spell, look for units (heroes and creeps) nearby, and deal damage
	local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), self:GetCaster(), radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
	for u,unit in pairs(units) do
		local dmgtype = nil
		if (self:GetCaster()==unit) then
			-- deal pure damage to yourself
			dmgtype = DAMAGE_TYPE_PURE
		else
			-- and magical damage to everyone else
			dmgtype = DAMAGE_TYPE_MAGICAL
		end

		-- the damage parameter for each unit
		local tabel = {
						victim = unit,
						attacker = self:GetCaster(),
						damage = dmg,
						damage_type = dmgtype,
						damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL, -- Optional, more can be added with + .. No flags = 0.
						ability = self	-- Optional, but we have an ability here (=self)
					}
		ApplyDamage( tabel ) -- deal damage
	end

	-- now we add a modifier to the caster, that makes him have lifesteal for some time
	self:GetCaster():AddNewModifier(
						self:GetCaster(), -- handle caster,
						self, -- handle optionalSourceAbility,
						"exampleabilitymodifier", -- string modifierName,
						{ duration = dur, lifesteal = initls } -- handle modifierData)
	)
end



-------------------------------------------------------------------------------------------------------------------------------
-- everything down from here is a modifier. LinkLuaModifier adds it to the game, so the AddNewModifier(..) knows where to find it.

--               modifiername used below ,       filepath            , weird valve thing
LinkLuaModifier( "exampleabilitymodifier", "abilities/exampleability", LUA_MODIFIER_MOTION_NONE )

exampleabilitymodifier = class({})

function exampleabilitymodifier:GetTexture() return "item_lifesteal" end

function exampleabilitymodifier:OnCreated( kv )
	-- we have to read the "lifesteal" number from the AddNewModifer(..) to use it.
	self.lifesteal = kv.lifesteal
end

function exampleabilitymodifier:OnRefresh( kv )
	self.lifesteal = kv.lifesteal
end

function exampleabilitymodifier:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED, -- OnAttackLanded (check the link below)
		-- MODIFIER_EVENT_ON_TELEPORTED, -- OnTeleported 
		-- MODIFIER_PROPERTY_MANA_BONUS, -- GetModifierManaBonus 

		-- can contain everything from the API
		-- https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/API

	}
end

-- function exampleabilitymodifier:GetModifierManaBonus(event) -- MODIFIER_PROPERTY_MANA_BONUS
	-- return 100
-- end

function exampleabilitymodifier:OnAttackLanded(event) -- MODIFIER_EVENT_ON_ATTACK_LANDED
	if self:GetParent()~=event.attacker then return end
	self:GetParent():Heal(self.lifesteal, self:GetAbility())
	self:GetParent():newParticleEffect(BUTT_PARTICLE_LIFESTEAL)
	self.lifesteal = self.lifesteal / 2
end