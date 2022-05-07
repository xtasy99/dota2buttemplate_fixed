BUTTINGS = BUTTINGS or {}
require("internal/utils/butt_api")

_Thinker = class({})

ListenToGameEvent("game_rules_state_change", function()
	if (GameRules:State_Get()==DOTA_GAMERULES_STATE_GAME_IN_PROGRESS) then
		Timers:CreateTimer( Buttings:GetQuick("COMEBACK_TIMER") *60, _Thinker.ComebackXP )
		Timers:CreateTimer( Buttings:GetQuick("COMEBACK_TIMER") *60, _Thinker.ComebackGold )
		Timers:CreateTimer( Buttings:GetQuick("ALT_TIME_LIMIT") *60, _Thinker.WinThinker )
		Timers:CreateTimer( _Thinker.XPThinker )
		-- Timers:CreateTimer( _Thinker.Outpost )
	end
end, self)

function _Thinker:ComebackXP()
	local team = 0
	local amt = nil
	for t,xp in pairs(TeamList:GetTotalEarnedXP()) do
		if (not amt) or (amt>xp) then
			team = t
			amt = xp
		end
	end
	for h,hero in pairs(HeroListButt:GetMainHeroesInTeam(team)) do
		hero:AddExperience(1, DOTA_ModifyXP_Unspecified, false, true)
	end
	return 60/Buttings:GetQuick("COMEBACK_XPPM") 
end

function _Thinker:ComebackGold()
	local team = 0
	local amt = nil
	for t,gold in pairs(TeamList:GetTotalEarnedGold()) do
		if (not amt) or (amt>gold) then
			team = t
			amt = gold
		end
	end
	for p,player in pairs(PlayerList:GetPlayersInTeam(team)) do
		PlayerResource:ModifyGold(p, 1, false, DOTA_ModifyGold_GameTick) 
	end
	return 60/Buttings:GetQuick("COMEBACK_GPM") 
end

function _Thinker:XPThinker()
	for h,hero in pairs(HeroListButt:GetMainHeroes()) do
		hero:AddExperience(1, DOTA_ModifyXP_Unspecified, false, true)
	end
	return 60/Buttings:GetQuick("XP_PER_MINUTE") 
end

function _Thinker:WinThinker()
	if (1==Buttings:GetQuick("ALT_WINNING") ) then
		local team = DOTA_TEAM_NOTEAM 
		local kills = 0
		for _,t in ipairs(TeamList:GetPlayableTeams()) do
			if (PlayerResource:GetTeamKills(t)>kills) then
				team = t
				kills = PlayerResource:GetTeamKills(t)
			end
		end
		GameRules:SetGameWinner(team)
	end
end

function _Thinker:Outpost()
	local units = LoadKeyValues(ADDON_FOLDER.."scripts/npc/npc_units_custom.txt")
	local delay = units.npc_dota_watch_tower and units.npc_dota_watch_tower.StartingTime
	if nil==delay then return end
	if "number"~=type(delay) then error("npc_dota_watch_tower.StartingTime is not a number",2) end
	Butt:ProtectAllOutposts(delay) -- protects all Outposts until 10:00
	-- refresh at 10:00 or new modifier
end