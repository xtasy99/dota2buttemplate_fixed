-- extra modifier? meeh
modifier_passive_gold = class({})
LinkLuaModifier("modifier_passive_gold_helper", "internal/modifier_passive_gold.lua", LUA_MODIFIER_MOTION_NONE)

function modifier_passive_gold:IsPermanent() return true end
function modifier_passive_gold:IsHidden() return true end

---
---	The modifier below helps cancel out normal GPM.
--- Unfortunately requires relatively 'constant' updating from normal dota gpm.
---

function modifier_passive_gold:OnCreated(data)
	if IsClient() then return end
	
	-- Change this based on Dota Wiki
	self.normalGPM = 95
	
	self.hero = self:GetParent()
	self.goldTickTime = data.gold_tick_time
	self.goldPerTick = data.gold_per_tick
	self.courierEntity = data.courier_entindex and EntIndexToHScript(data.courier_entindex)
	self.alwaysGold = (0==data.always_gold)
	self.reliable = true	-- As of (forgot update number), gpm is reliable.

	ListenToGameEvent("game_rules_state_game_in_progress",function()
		self.hero.passive_gold_gain = 0
		self:StartIntervalThink(self.goldTickTime)
		self.hero:AddNewModifier(self.hero, nil, "modifier_passive_gold_helper", {gpm = self.normalGPM})
	end, nil)
end

function modifier_passive_gold:OnIntervalThink()
	if self.goldTickTime >= 60/self.normalGPM then -- If GPM is less than or equal to 60
		-- I dont really know how to decrease GPM without making the gold counter spaz out
		-- Here it is anyway
		self.hero:ModifyGold(self.hero.passive_gold_gain, self.reliable, DOTA_ModifyGold_GameTick)
		self.hero.passive_gold_gain = 0
	else
		-- This modifier and the helper go back and forth with the passive gold gain
		-- The logic should accurately represent the gpm at every tick.
		self.hero.passive_gold_gain = self.hero.passive_gold_gain + 1
		if self.hero.passive_gold_gain > 0 then
			self.hero:ModifyGold(self.hero.passive_gold_gain, self.reliable, DOTA_ModifyGold_GameTick)
			self.hero.passive_gold_gain = 0
		end
	end
end

-- Helper Modifier
modifier_passive_gold_helper = class({})

function modifier_passive_gold_helper:IsPermanent() return true end
function modifier_passive_gold_helper:IsHidden() return true end

function modifier_passive_gold_helper:OnCreated(data)
	if IsClient() then return end
	self:StartIntervalThink(60/data.gpm)
end

function modifier_passive_gold_helper:OnIntervalThink()
	local hero = self:GetParent()
	self:GetParent().passive_gold_gain = self:GetParent().passive_gold_gain - 1
end