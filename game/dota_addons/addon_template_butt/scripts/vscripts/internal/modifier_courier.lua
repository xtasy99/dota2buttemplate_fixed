modifier_courier =  class({})

-- check out https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/API

-- The modifier Tooltip is inside resource/addon_english.txt (Have fun playing)


-- function modifier_courier:GetTexture() return "alchemist_chemical_rage" end -- get the icon from a different ability

function modifier_courier:IsPermanent() return true end
function modifier_courier:RemoveOnDeath() return false end
-- function modifier_courier:IsHidden() return true end 	-- we can hide the modifier
function modifier_courier:IsDebuff() return false end 	-- make it red or green

function modifier_courier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE, -- GetModifierMoveSpeedOverride 
		MODIFIER_EVENT_ON_MODEL_CHANGED , -- OnModelChanged   
		MODIFIER_EVENT_ON_DEATH, -- OnDeath
		MODIFIER_EVENT_ON_RESPAWN, -- OnRespawn 
		MODIFIER_PROPERTY_VISUAL_Z_DELTA, -- GetVisualZDelta

		-- MODIFIER_PROPERTY_RESPAWNTIME , -- GetModifierConstantRespawnTime  
		-- these functions are usually called with everyone on the map
		-- check the link for more
		-- https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/API#modifierfunction
	}
	return funcs
end

if IsServer() then

	function modifier_courier:OnRespawn(event)
		if event.unit~=self:GetParent() then return end -- only affect the own hero
		self:updateHealth()
	end

	function modifier_courier:OnDeath(event)
		if event.unit~=self:GetParent() then return end -- only affect the own hero
		local level = self:GetStackCount()
		self:GetParent():SetUnitCanRespawn(false)
		self:StartIntervalThink(level * 7 + 43)
	end

	function modifier_courier:OnIntervalThink()
		self:GetParent():SetUnitCanRespawn(true)
		self:GetParent():RespawnUnit()
		self:StartIntervalThink(-1)
		self:updateHealth()
	end

	function modifier_courier:OnStackCountChanged(old)
		local level = self:GetStackCount()
		local courier = self:GetParent()
		courier:SetDeathXP( level * 20 + 15 ) 
		courier:SetMaximumGoldBounty( level * 5 + 20 ) 
		courier:SetMinimumGoldBounty( level * 5 + 20 )
		self:updateHealth()	
		if (level>=5) then
			self.flying = true
			self:OnModelChanged()
		end
		if (level>=10) then
			courier:FindAbilityByName("courier_burst"):SetLevel(1)
		end
		if (level>=15) then
			-- can place wards
		end
		if (level>=20) then
			courier:FindAbilityByName("courier_shield"):SetLevel(1)
		end
		if (level>=25) then
			-- can use items
		end
	end

	function modifier_courier:OnCreated(event)
		local maxLevel = 30
		self.startlevel = math.min(maxLevel, event.level or 1)
		self.flying = false
		self:SetStackCount(self.startlevel)
		self:StartIntervalThink(5) -- fix health bug

		self.levelListener = ListenToGameEvent("dota_player_gained_level", function(self,event) -- for k,v in pairs(event) do			print("mod dota_player_gained_level",IsClient(),event,k,v)		end
			local hero = EntIndexToHScript(event.hero_entindex)
			if (self:GetCaster()~=hero) then return end
			local newCourierLevel = self.startlevel - 1 + event.level
			self:SetStackCount(math.min(newCourierLevel, maxLevel))
		end, self)
	end

	function modifier_courier:updateHealth()
		local level = self:GetStackCount()
		local courier = self:GetParent()
		local percHealth = courier:GetHealth()/courier:GetMaxHealth()
		-- print("GetMaxHealth",courier:GetMaxHealth())
		courier:SetMaxHealth(level * 10 +  60)
		courier:SetHealth(percHealth*courier:GetMaxHealth())
		-- print("GetMaxHealth",courier:GetMaxHealth())
	end

	function modifier_courier:OnModelChanged()
		if not self.flying then return end
		self:GetParent():SetOriginalModel("models/props_gameplay/donkey_wings.vmdl")
		self:GetParent():SetModel("models/props_gameplay/donkey_wings.vmdl")
	end

	function modifier_courier:OnDestroy(event)
		StopListeningToGameEvent(self.levelListener)
	end


elseif IsClient() then
	
	-- game logic is not working here

	function modifier_courier:GetVisualZDelta()
		local height = self:isFlying() and 220 or 0
		-- print("GetVisualZDelta",IsServer(),height,self:isFlying())
		return height
	end

end

function modifier_courier:isFlying()
	local level = self:GetStackCount()
	return level>=5
end

function modifier_courier:GetModifierMoveSpeedOverride()
	local courier = self:GetParent()
	-- print("GetMaxHealth",IsServer(),courier:GetMaxHealth())
	local level = self:GetStackCount()
	-- if self.updateHealth then self:updateHealth() end
	return level * 10 + 270 
end
-- function modifier_courier:GetModifierConstantRespawnTime()	return     end

function modifier_courier:CheckState()
	return {
		[MODIFIER_STATE_FLYING] =  self:isFlying(),
		-- https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/API#modifierstate
	}
end
