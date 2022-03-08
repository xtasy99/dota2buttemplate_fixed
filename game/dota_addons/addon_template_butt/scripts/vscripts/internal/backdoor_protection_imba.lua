backdoor_protection_imba = class({})

function backdoor_protection_imba:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
    }
end

function backdoor_protection_imba:IsHidden()
	return true
end

function backdoor_protection_imba:GetModifierConstantHealthRegen()
	if self:GetParent():HasModifier("modifier_backdoor_protection_active") then
        return 9999
    end
    return 0
end