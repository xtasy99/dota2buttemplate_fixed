-- extra modifier? meeh

modifier_passive_gold = class({})


function modifier_passive_gold:IsPermanent() return true end
function modifier_passive_gold:IsHidden() return true end

function modifier_passive_gold:OnCreated(data)
	if IsClient() then return end
	
	self.goldTickTime = data.gold_tick_time
	self.goldPerTick = data.gold_per_tick
	self.courierEntity = data.courier_entindex and EntIndexToHScript(data.courier_entindex)
	self.alwaysGold = (0==data.always_gold)
	self.reliable = false

	ListenToGameEvent("game_rules_state_game_in_progress",function()
		self:StartIntervalThink(self.goldTickTime)
	end, nil)
end

function modifier_passive_gold:OnIntervalThink()
	local hero = self:GetParent()
	if self.alwaysGold then
		hero:ModifyGold(self.goldPerTick, self.reliable, DOTA_ModifyGold_GameTick)
	else
		-- Put your conditions here when passive gold is ON/OFF
		-- Custom couriers can be connected with passive gold, in vanilla they are not connected
		if BUTTINGS.FREE_COURIER == 0 then
			local courier = self.courierEntity
			if courier and courier.IsAlive then
				if courier:IsAlive() then
					hero:ModifyGold(self.goldPerTick, self.reliable, DOTA_ModifyGold_GameTick)
				end
			end
		else
			hero:ModifyGold(self.goldPerTick, self.reliable, DOTA_ModifyGold_GameTick)
		end
	end
end
