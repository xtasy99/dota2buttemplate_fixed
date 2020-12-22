BUTTINGS = BUTTINGS or {BONUS_COURIER_SPEED = 0, COURIER_INVULNERABLE = 0}
modifier_courier_speed = class({})
function modifier_courier_speed:IsHidden() return true end
function modifier_courier_speed:IsPermanent() return true end
if IsServer() then
    function modifier_courier_speed:CheckState()
        if BUTTINGS.COURIER_INVULNERABLE == 1 then
            return {[MODIFIER_STATE_INVULNERABLE ] = true}
        else return {[MODIFIER_STATE_INVULNERABLE ] = false} end 
    end

    function modifier_courier_speed:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
    function modifier_courier_speed:GetModifierMoveSpeedBonus_Percentage() return BUTTINGS.BONUS_COURIER_SPEED end
end