Butt = class({})

-----------------------
-- extend PlayerList --
-----------------------

PlayerList = class({})

function PlayerList:GetAllPlayers()
	local out = {}
	for p=0,DOTA_MAX_PLAYERS do
		if (PlayerResource:IsValidPlayer(p)) then
			out[p] = PlayerResource:GetPlayer(p)
		else
			out[p] = nil
		end
	end
	return out
end

function PlayerList:GetValidTeamPlayers()
	local out = {}
	for p=0,DOTA_MAX_PLAYERS do
		if (PlayerResource:IsValidTeamPlayer(p)) then
			out[p] = PlayerResource:GetPlayer(p)
		else
			out[p] = nil
		end
	end
	return out
end

function PlayerList:GetPlayersInTeam(teamID) -- returns playerID and player
	local out = {}
	for p=0,DOTA_MAX_PLAYERS do
		if (PlayerResource:IsValidPlayer(p)) and (PlayerResource:GetTeam(p)==teamID) then
			out[p] = PlayerResource:GetPlayer(p)
		else
			out[p] = nil
		end
	end
	return out
end

function PlayerList:GetFirstPlayers() -- get one player per team
	local out = {}
	for p=0,DOTA_MAX_PLAYERS do
		local team = PlayerResource:GetTeam(p)
		if (not out[team]) then
			out[team] = PlayerResource:GetPlayer(p)
		end
	end
	return out
end

---------------------------
-- extend PlayerResource --
---------------------------

PlayerResourceButt = class({})

function PlayerResourceButt:GetFriendlyPlayers(playerID) -- returns table with playerID and player
	local teamID = PlayerResource:GetTeam(playerID)
	local out = {}
	for p=0,DOTA_MAX_PLAYERS do
		if (PlayerResource:IsValidPlayer(p)) and (PlayerResource:GetTeam(p)==teamID) then
			out[p] = PlayerResource:GetPlayer(p)
		else
			out[p] = nil
		end
	end
	return out
end

function PlayerResourceButt:GetFriendlyHeroes(playerID) -- Friendly HeroList
	local teamID = PlayerResource:GetTeam(playerID)
	local out = HeroList:GetAllHeroes()
	for h,hero in pairs(out) do
		if (hero:GetTeam()~=teamID) then
			out[h] = nil
		end
	end
	return out
end

function PlayerResourceButt:GetMainFriendlyHeroes(playerID) -- One Hero per Person on playerID
	local teamID = PlayerResource:GetTeam(playerID)
	local out = {}
	for p=0,DOTA_MAX_PLAYERS do
		if (PlayerResource:GetSelectedHeroEntity(p)) and (PlayerResource:GetTeam(p)==teamID) then
			out[p] = PlayerResource:GetSelectedHeroEntity(p)
		else
			out[p] = nil
		end
	end
	return out
end

---------------------
-- extend HeroList --
---------------------

HeroListButt = class({})

function HeroListButt:GetHeroesInTeam(teamID) -- filters team
	local out = HeroList:GetAllHeroes()
	for h,hero in pairs(out) do
		if (hero:GetTeam()==teamID) then
		else
			out[h] = nil
		end
	end
	return out
end

function HeroListButt:GetMainHeroes() -- filters main Heroes
	local out = HeroList:GetAllHeroes()
	for h,hero in pairs(out) do
		if (hero:GetPlayerOwner()) and (hero==hero:GetPlayerOwner():GetAssignedHero()) then
		else
			out[h] = nil
		end
	end
	return out
end

function HeroListButt:GetMainHeroesInTeam(teamID) -- filters main Heroes and team
	local out = HeroList:GetAllHeroes()
	for h,hero in pairs(out) do
		if (hero:GetPlayerOwner()) and (hero==hero:GetPlayerOwner():GetAssignedHero()) and (hero:GetTeam()==teamID) then
		else
			out[h] = nil
		end
	end
	return out
end

function HeroListButt:GetOneHeroPerTeam()
	local out = {}
	for h,hero in pairs(HeroList:GetAllHeroes()) do
		local team = hero:GetTeam()
		if (not out[team]) then
			out[team] = hero
		end
	end
	return out
end


---------------------
-- TeamList --
---------------------

TeamList = class({})

function TeamList:GetPlayableTeams()
	local out = {}
	for t=2,14 do
		-- print("TeamList",GameRules:GetCustomGameTeamMaxPlayers(t))
		if (GameRules:GetCustomGameTeamMaxPlayers(t)>0) then
			table.insert(out,t)
		end
	end
	return out
end


function TeamList:GetFreeCouriers()
	for t,hero in pairs(HeroListButt:GetOneHeroPerTeam()) do
		if (not PlayerResource:GetNthCourierForTeam(0,t)) then
			local courier = hero:AddItemByName("item_courier")
			-- hero:CastAbilityImmediately(courier, hero:GetPlayerID())
			courier:CastAbility()
		end
	end
end

function TeamList:GetTotalEarnedGold()
	local out = {}
	for p=0,DOTA_MAX_PLAYERS do
		local team = PlayerResource:GetTeam(p)
		out[team] = PlayerResource:GetTotalEarnedGold(p) + (out[team] or 0)
	end
	return out
end

function TeamList:GetTotalEarnedXP()
	local out = {}
	for p=0,DOTA_MAX_PLAYERS do
		local team = PlayerResource:GetTeam(p)
		out[team] = PlayerResource:GetTotalEarnedXP(p) + (out[team] or 0)
	end
	return out
end


---------------------
-- TeamResource --
---------------------

TeamResource = class({})

function TeamResource:GetTotalEarnedGold(teamID)
	local out = 0
	for p=0,DOTA_MAX_PLAYERS do
		if (PlayerResource:IsValidPlayer(p)) and (PlayerResource:GetTeam(p)==teamID) then
			out = out + PlayerResource:GetTotalEarnedGold(p)
		end
	end
	return out
end

function TeamResource:GetTotalEarnedXP(teamID)
	local out = 0
	for p=0,DOTA_MAX_PLAYERS do
		if (PlayerResource:IsValidPlayer(p)) and (PlayerResource:GetTeam(p)==teamID) then
			out = out + PlayerResource:GetTotalEarnedXP(p)
		end
	end
	return out
end

function TeamResource:GetKills(teamID)
	return PlayerResource:GetTeamKills(teamID)
end

function TeamResource:GetFountain(teamID)
	local fountain = Entities:FindByClassname(nil, "ent_dota_fountain")
	while fountain and  fountain:GetTeamNumber() ~= teamID do
		fountain = Entities:FindByClassname(fountain, "ent_dota_fountain")
	end
	return fountain
end

function TeamResource:GetShop(teamID)
	local fountain = TeamResource:GetFountain(teamID)
	for _,ent in pairs(Entities:FindAllInSphere(fountain:GetAbsOrigin(),1000)) do
		if ("ent_dota_shop"==ent:GetClassname()) then
			return ent
		end
	end
	return fountain
end

--------------------------
-- extend CDOTA_BaseNPC --
--------------------------

function CDOTA_BaseNPC:GetAllAbilities() -- returns Abilitynumber and Ability (handle)
	local out = {}
	for i=0,29 do
		local abil = self:GetAbilityByIndex(i)
		if abil then
			out[abil:GetAbilityIndex()] = abil
		end
	end
	return out
end

function CDOTA_BaseNPC:GetAllTalents() -- returns Abilitynumber and Talent (handle)
	local out = {}
	for i=0,29 do
		local abil = self:GetAbilityByIndex(i)
		if (abil) and (abil:GetName():find("special_bonus_") == 1) then
			out[abil:GetAbilityIndex()] = abil
		end
	end
	return out
end

function CDOTA_BaseNPC:AddNewModifierButt(caster, optionalSourceAbility, modifierName, modifierData)
	local file = "modifiers/"..modifierName
	if pcall(require,file) then
		LinkLuaModifier(modifierName, file, LUA_MODIFIER_MOTION_NONE)
	end
	self:AddNewModifier(caster, optionalSourceAbility, modifierName, modifierData)
end

function CDOTA_BaseNPC:RemoveItemByName( itemName )
	for i=1,10 do
		local item = self:GetItemInSlot(i)
		if (item) and (item:GetName()==itemName) then
			self:RemoveItem(item)
			break
		end
	end
end

------------
-- Global --
------------

function HUDError(message, playerID)
	if ("number"==type(playerID)) then
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "dota_hud_error_message_player", {splitscreenplayer= 0, reason= 80, message= message})
	else
		CustomGameEventManager:Send_ServerToAllClients("dota_hud_error_message_player", {splitscreenplayer= 0, reason= 80, message= "All Players: "..message})
	end
end

function say(...)
	local str = ""
	for i,v in ipairs({...}) do
		str = str..tostring(v).." "
	end
	Say(nil,str,true)
end

function CreateModifierThinkerButt( hCaster, hAbility, modifierName, paramTable, vOrigin, nTeamNumber, bPhantomBlocker )
	local file = "modifiers/"..modifierName
	if pcall(require,file) then
		LinkLuaModifier(modifierName, file, LUA_MODIFIER_MOTION_NONE)
	end
	CreateModifierThinker( hCaster, hAbility, modifierName, paramTable, vOrigin, nTeamNumber, bPhantomBlocker )
end

function Butt:Roshan()
	return Entities:FindByClassname(nil, "npc_dota_roshan")
end

function Butt:AllOutposts()
	return Entities:FindAllByClassname("npc_dota_watch_tower")
end

function Butt:UnProtectAllOutposts()
	for u,unit in pairs(Butt:AllOutposts()) do
		unit:RemoveModifierByName("modifier_watch_tower_invulnerable")
		unit:RemoveModifierByName("modifier_watch_tower_invulnerable_butt")
	end
end

function Butt:ProtectAllOutposts(duration)
	if duration~=nil and "number"~=type(duration) then error("ProtectAllOutposts: number expected",2) end
	require("internal/modifier_watch_tower_invulnerable_butt")
	for u,unit in pairs(Butt:AllOutposts()) do
		unit:AddNewModifierButt(unit, nil, "modifier_watch_tower_invulnerable_butt", {duration = duration})
		unit:RemoveModifierByName("modifier_watch_tower_invulnerable")
	end
end

function Butt:OldSideshopLocations()
	return {Vector(7500,-4128,256),Vector(-7400,4440,256)}
end

function Butt:CreateSideShop(location)
	CreateUnitByNameAsync(
		"ent_dota_shop",
		location,
		true,  -- bFindClearSpace,
		nil,
		nil,
		5,
		function(shop)
			shop:SetShopType(DOTA_SHOP_SIDE)
		end
	)
	SpawnDOTAShopTriggerRadiusApproximate(location,600):SetShopType(DOTA_SHOP_SIDE)
end

function IsMonkeyKingClone(unit)
	return unit:HasModifier("modifier_monkey_king_fur_army_soldier_hidden")
end