modifier_watch_tower_capturing_butt = class({})

LinkLuaModifier("modifier_watch_tower_capturing_butt", "internal/modifier_watch_tower_capturing_butt", LUA_MODIFIER_MOTION_NONE)

function modifier_watch_tower_capturing_butt:IsPermanent() return true end
function modifier_watch_tower_capturing_butt:IsHidden() return true end


function modifier_watch_tower_capturing_butt:CheckState()
	return {
		-- [MODIFIER_STATE_INVULNERABLE] =  true,
		-- [MODIFIER_STATE_NO_TEAM_SELECT] =  true,
		-- [MODIFIER_STATE_NO_HEALTH_BAR] =  true,
	}
end

-- MODIFIER_ATTRIBUTE_MULTIPLE 