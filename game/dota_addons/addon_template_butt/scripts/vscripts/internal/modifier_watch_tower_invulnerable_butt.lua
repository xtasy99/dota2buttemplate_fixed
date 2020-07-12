modifier_watch_tower_invulnerable_butt = class({})

LinkLuaModifier("modifier_watch_tower_invulnerable_butt", "internal/modifier_watch_tower_invulnerable_butt", LUA_MODIFIER_MOTION_NONE)
if IsClient() then return end
local kv = LoadKeyValues(ADDON_FOLDER.."scripts/npc/npc_units_custom.txt").npc_dota_watch_tower

function modifier_watch_tower_invulnerable_butt:IsPermanent() return true end
function modifier_watch_tower_invulnerable_butt:IsDebuff() return false end


function modifier_watch_tower_invulnerable_butt:OnCreated(event)
	local dur = kv.StartingTime or -1
	self:StartIntervalThink(dur)
end

function modifier_watch_tower_invulnerable_butt:OnIntervalThink()
	self:Destroy()
end


function modifier_watch_tower_invulnerable_butt:CheckState()
	return {
		[MODIFIER_STATE_INVULNERABLE] =  true,
		[MODIFIER_STATE_NO_TEAM_SELECT] =  true,
		[MODIFIER_STATE_NO_HEALTH_BAR] =  true,
	}
end
