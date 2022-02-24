if (not IsInToolsMode()) then return end

require("internal/utils/butt_api")

local cheatStart

ListenToGameEvent("player_chat", function(keys)
	local teamonly = keys.teamonly
	local userID = keys.userid
	local playerID = keys.playerid -- attempt to index a nil value
	local hero = playerID and PlayerResource:GetSelectedHeroEntity(playerID)
	local text = keys.text
	
	if ("-mods"==text) and (playerID) then
		if (hero) then
			for m,mod in pairs(hero:FindAllModifiers()) do
				print("Modifier:",mod:GetName())
			end
		end
	elseif ("-courier"==text) and (playerID) then
		TeamList:GetFreeCouriers()
	elseif ("-quick"==text) and (playerID) then
		cheatStart()
	elseif ("-nearents"==text) and (playerID) then
		for _,ent in pairs(Entities:FindAllInSphere(hero:GetAbsOrigin(),800)) do
			print("Near Entities:",ent:GetClassname(),ent:GetName(),ent:entindex(),"Team",ent:GetTeam())
		end
	elseif ("-entities"==text) and (playerID) then
		local iter = Entities:First()
		while(iter) do
			if (iter:GetName()~="") then print("Entities:",iter:GetClassname(),iter:GetName(),iter:entindex(),"Team",iter:GetTeam()) end
			iter = Entities:Next(iter)
		end
	elseif ("-abils"==text) and (playerID) then
		for k,v in pairs(hero:GetAllAbilities()) do
			print("Ability:",k,v,v:GetName())
		end
	elseif ("-entmods"==text) and (playerID) then
		for _,ent in pairs(Entities:FindAllInSphere(hero:GetAbsOrigin(),800)) do
			if ent.FindAllModifiers then
				for _,mod in pairs(ent:FindAllModifiers()) do
					print("Ent Modifiers:",ent:GetClassname(),ent:GetName(),mod:GetName())
					-- PrintTable(mod)
				end
			end
		end
	elseif ("-pos"==text) and (playerID) then
		say("Position: "..tostring(hero:GetAbsOrigin()))
	elseif ("-outpost 1"==text) and (playerID) then
		Butt:ProtectAllOutposts()
	elseif ("-outpost 0"==text) and (playerID) then
		Butt:UnProtectAllOutposts()
	end
end, nil)

local l2 = CustomGameEventManager:RegisterListener("butt_on_clicked", function(_,kv)
	local name = kv.button
	if ("CHEAT_QUICK"==name) then
		cheatStart()
	end
end)

function cheatStart()
	Tutorial:SelectHero("npc_dota_hero_furion")
	Tutorial:ForceGameStart()
	PlayerResource:SetGold(0, 9876, true)
	GameRules:GetGameModeEntity():SetCameraDistanceOverride(1500)
	-- GameRules:GetGameModeEntity():SetThink(function()
	-- 	print("asd")
	-- 	local hero = PlayerResource:GetSelectedHeroEntity(0)
	-- 	if (not hero) then return 0.3 end
	-- 	hero:GetAbilityByIndex(0):SetLevel(1)
	-- 	hero:GetAbilityByIndex(1):SetLevel(1)
	-- 	hero:GetAbilityByIndex(2):SetLevel(1)
	-- 	hero:GetAbilityByIndex(5):SetLevel(1)
	-- 	hero:SetAbilityPoints(-3)
	-- 	return nil
	-- end, 0.1)
end