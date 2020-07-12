modifier_watch_tower_butt = class({})

LinkLuaModifier("modifier_watch_tower_butt", "internal/modifier_watch_tower_butt", LUA_MODIFIER_MOTION_NONE)

local kv = LoadKeyValues(ADDON_FOLDER.."scripts/npc/npc_units_custom.txt").npc_dota_watch_tower

function modifier_watch_tower_butt:IsPermanent() return true end
function modifier_watch_tower_butt:IsHidden() return true end
function modifier_watch_tower_butt:GetModifierAura() return "modifier_truesight" end
function modifier_watch_tower_butt:GetAuraRadius() return kv.TruesightRadius end

	


-- MODIFIER_ATTRIBUTE_MULTIPLE 