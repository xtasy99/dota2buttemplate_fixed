BUTT_PARTICLE_LIFESTEAL = "generic_lifesteal"
BUTT_PARTICLE_COINS = "lasthit_coins_local"
BUTT_PARTICLE_MANABURN = "generic_manaburn"
BUTT_PARTICLE_SCREEN_BLOOD = "screen_blood_splatter"

function CDOTA_BaseNPC:newParticleEffect(i, optionalPlayerEnt)
	if ("string"==type(i)) then
		local nFXIndex = optionalPlayerEnt and ParticleManager:CreateParticleForPlayer( ("particles/generic_gameplay/"..i..".vpcf"), PATTACH_ABSORIGIN_FOLLOW, self, optionalPlayerEnt )
		                 or                    ParticleManager:CreateParticle( ("particles/generic_gameplay/"..i..".vpcf"), PATTACH_ABSORIGIN_FOLLOW, self )
		ParticleManager:ReleaseParticleIndex( nFXIndex )
		return nFXIndex
	elseif (i==BUTT_PARTICLE_LIFESTEAL) then
		local nFXIndex = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self )
		ParticleManager:ReleaseParticleIndex( nFXIndex )
		return nFXIndex
	elseif (i==BUTT_PARTICLE_COINS) then
		local nFXIndex = ParticleManager:CreateParticle( "particles/generic_gameplay/lasthit_coins_local.vpcf", PATTACH_ABSORIGIN_FOLLOW, self )
		ParticleManager:ReleaseParticleIndex( nFXIndex )
		return nFXIndex
	elseif (i==3) then
	end
end