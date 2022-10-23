----GAME MODE SAVE ID
-- Edit it if you add new options or want to keep your mode's saves unique compared to other template users. BUT!!! if you want the users settings to be availalbe from other modes, do not change the default.
-- This should be integer value (max 64 bit) that is unique to your game mode. obvious meme numbers may be taken so try not to over lap every 1337, 69 and 420 or combinations of them :)
GAMEMODE_SAVE_ID = 987654321
----




local JSON = require("dkjson")
BUTTINGS = {
}
local base64 = require("base64")
function ReadKv()
	local file = LoadKeyValues('scripts/kv/settings.kv')
	if file == nil or not next(file) then
		print("empty settings :/")
		return {}
	end
	return file
end
BUTTINGS = ReadKv()


function split (inputstr, sep)
	if sep == nil then
			sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			table.insert(t, str)
	end
	return t
end


Buttings = class({})
_G.Buttings = Buttings
Buttings.QuickKeys = {}
function Buttings:GetQuick(key)
	if Buttings.QuickKeys[key] == nil then
		for k,category in pairs(BUTTINGS) do
			if type(category) == "table" then
				if key == k and category.ENABLED ~=nil then
					Buttings.QuickKeys[key] = category.ENABLED --correct way.
					return Buttings.QuickKeys[key]
				end
				if key == k and category.VALUE ~= nil then
					Buttings.QuickKeys[key] = category.VALUE --incorrect way but supported.
					return Buttings.QuickKeys[key]
				end
				for catkey,val in pairs(category) do
					if type(category) == "table" then
						if catkey == key and val.VALUE ~= nil then
							Buttings.QuickKeys[key] = val.VALUE --correct way.
							return Buttings.QuickKeys[key]
						end
						if catkey == key and val.ENABLED ~= nil then
							Buttings.QuickKeys[key] = val.ENABLED --incorrect way but supported.
							return Buttings.QuickKeys[key]
						end
					end
				end
			end
		end
		print("not found ",key)
		return 0
	end
	return Buttings.QuickKeys[key]
end

function Buttings:GetValue(category,key)
	if key == nil then
		return Buttings:GetQuick(category)
	end
	if key == "ENABLED" then
		if (BUTTINGS[category] ~= nil and BUTTINGS[category].ENABLED ~= nil) then
			return BUTTINGS[category].ENABLED
		else
			print("not found ",category,key)
		end
		return 0
	end
	if (BUTTINGS[category] ~= nil and BUTTINGS[category][key] ~= nil and BUTTINGS[category][key].VALUE ~= nil) then
		return BUTTINGS[category][key].VALUE
	else
		print("not found ",category,key)
	end
	return 0
end

function Buttings:SetValue(category,key,value)
	local path = category .. "&" .. key .. "&"
	if BUTTINGS[category][key].VALUE ~= nil then
		BUTTINGS[category][key].VALUE = value
		path = path .. "VALUE"
	else
		BUTTINGS[category][key].ENABLED = value
		path = path .. "ENABLED"
	end
	CustomGameEventManager:Send_ServerToAllClients("butt_setting_changed", {setting = path,value = value})
end

function Buttings:LoadBase64(s)
	local t = split(s,"|")
	for i=1,#t do
		local o = split(t[i],"&")
		if tonumber(o[3]) ~= nil then
			Buttings:SetValue(o[1],o[2],tonumber(o[3]))
		else
			Buttings:SetValue(o[1],o[2],o[3])
		end
	end
end

function Buttings:GenerateSave(bChangesOnly)
	bChangesOnly = bChangesOnly or true
	local s = ""
	local original = LoadKeyValues('scripts/kv/settings.kv')
	if original == nil or not next(original) then
		print("empty settings :/")
		return
	end
	for category,content in pairs(BUTTINGS) do
		if type(content) == "table" then
			for key,val in pairs(content) do
				if original[category] ~= nil and original[category][key] ~= nil then
					if key == "ENABLED" and original[category][key] ~= val then
						s = s .. category .. "&" .. key .. "&" .. val .. "|"
					elseif key == "VALUE" and original[category][key] ~= val then
						s = s .. category .. "&" .. key .. "&" .. val .. "|"
					else
						if type(original[category][key]) == "table" then
							if original[category][key].ENABLED ~= nil and val.ENABLED ~= nil then
								if original[category][key].ENABLED ~= val.ENABLED or not bChangesOnly then
									print(category,key,val.ENABLED)
									s = s .. category .. "&" .. key .. "&" .. val.ENABLED .. "|"
								end
							elseif original[category][key].VALUE ~= nil and val.VALUE ~= nil then
								if original[category][key].VALUE ~= val.VALUE or not bChangesOnly then
									print(category,key,val.VALUE)
									s = s .. category .. "&" .. key .. "&" .. val.VALUE .. "|"
								end
							end
						end
					end
				end
			end
		end
	end
	if string.len(s)  > 0 then
		s = string.sub(s,1,-2)
	end
	print(s)
	return s
end


ListenToGameEvent("game_rules_state_change", function()
	if (GameRules:State_Get()==DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP) then
		Buttings:LoadAllSlots()
		CustomGameEventManager:RegisterListener("slot_load", function(_,kv)
			Buttings:ApplySlot(kv.slot)
		end)
		CustomGameEventManager:RegisterListener("slot_save", function(_,kv)
			Buttings:SendSettingSave(kv.slot)
		end)
		if IsInToolsMode() then
			CustomGameEventManager:RegisterListener("slot_preset_save", function(_,kv)
				Buttings:SendPresetSave(kv.slot)
			end)
		end
		CustomGameEventManager:RegisterListener("slot_preset_load", function(_,kv)
			Buttings:GetSettingPreset(kv.slot)
		end)
	end
	if (GameRules:State_Get()==DOTA_GAMERULES_STATE_HERO_SELECTION) then
        Buttings:SendSettingSave(0)
    end
end,nil)

function Buttings:SendSettingSave(slot)
	local host = Buttings:GetHostId()
    local steamid = tostring(PlayerResource:GetSteamID(host))
    if steamid == "0" then
        print("nope, it's a bot!")
        return
    end
    local url = "https://api.dotabut.com/settings"
    local req = CreateHTTPRequestScriptVM("POST", url)
	local save = Buttings:GenerateSave()
    req:SetHTTPRequestHeaderValue("Dedicated-Server-Key", GetDedicatedServerKey("v1"))
    req:SetHTTPRequestGetOrPostParameter('steamid', steamid)
    req:SetHTTPRequestGetOrPostParameter('gamemode', tostring(GAMEMODE_SAVE_ID))
    req:SetHTTPRequestGetOrPostParameter('slot', tostring(slot))
    req:SetHTTPRequestGetOrPostParameter('data', save)
    req:Send(function(res)
        if res.StatusCode ~= 200 then
            print("something went wrong")
        else
            print("all ok")
			CustomNetTables:SetTableValue("butt_settings", "slot_" .. slot, {data = save})
        end
    end)
end


function Buttings:SendPresetSave(slot)
	local host = Buttings:GetHostId()
    local steamid = tostring(PlayerResource:GetSteamID(host))
    if steamid == "0" then
        print("nope, it's a bot!")
        return
    end
    local url = "https://api.dotabut.com/settings"
    local req = CreateHTTPRequestScriptVM("POST", url)
	local save = Buttings:GenerateSave()
    req:SetHTTPRequestHeaderValue("Dedicated-Server-Key", GetDedicatedServerKey("v1"))
    req:SetHTTPRequestGetOrPostParameter('steamid', steamid)
    req:SetHTTPRequestGetOrPostParameter('gamemode', tostring(GAMEMODE_SAVE_ID))
    req:SetHTTPRequestGetOrPostParameter('slot', tostring(slot))
    req:SetHTTPRequestGetOrPostParameter('data', save)
    req:Send(function(res)
        if res.StatusCode ~= 200 then
            print("something went wrong")
        else
            print("all ok")
			CustomNetTables:SetTableValue("butt_settings", "slot_preset_" .. slot, {data = save})
        end
    end)
end

function Buttings:LoadAllSlots()
	for i=0,2 do
		Buttings:GetSettingSave(i)
	end
end

function Buttings:ApplySlot(slot)
	local data = CustomNetTables:GetTableValue("butt_settings", "slot_" .. slot)
	if data.data ~= nil then
		Buttings:LoadBase64(data.data)
	end
end

function Buttings:ApplySlotPreset(slot)
	local data = CustomNetTables:GetTableValue("butt_settings", "slot_" .. slot)
	if data.data ~= nil then
		Buttings:LoadBase64(data.data)
	end
end


function Buttings:GetHostId()
	for p=0,DOTA_MAX_PLAYERS do
		local player = PlayerResource:GetPlayer(p)
		if player ~= nil then
			if GameRules:PlayerHasCustomGameHostPrivileges(player) then return p end
		end
	end
	return 0
end

function Buttings:GetSettingSave(slot)
	local host = Buttings:GetHostId()
    local steamid = tostring(PlayerResource:GetSteamID(host))
    if steamid == "0" then
        print("nope, it's a bot!")
        return
    end
    local url = "https://api.dotabut.com/settings/" .. steamid .. "/" .. GAMEMODE_SAVE_ID .. "/" .. slot
    local req = CreateHTTPRequestScriptVM("GET", url)
    req:SetHTTPRequestHeaderValue("Dedicated-Server-Key", GetDedicatedServerKey("v1"))
    req:Send(function(res)
        if res.StatusCode ~= 200 then
            print("something went wrong")
        else
			print(res.Body)
			local data = JSON.decode(res.Body)
			print(data)
			CustomNetTables:SetTableValue("butt_settings", "slot_" .. slot, data)
        end
    end)
end

function Buttings:GetSettingPreset(slot)
	local host = Buttings:GetHostId()
    local steamid = tostring(PlayerResource:GetSteamID(host))
    if steamid == "0" then
        print("nope, it's a bot!")
        return
    end
    local url = "https://api.dotabut.com/settings/0/" .. GAMEMODE_SAVE_ID .. "/" .. slot
    local req = CreateHTTPRequestScriptVM("GET", url)
    req:SetHTTPRequestHeaderValue("Dedicated-Server-Key", GetDedicatedServerKey("v1"))
    req:Send(function(res)
        if res.StatusCode ~= 200 then
            print("something went wrong")
        else
			print(res.Body)
			local data = JSON.decode(res.Body)
			print(data)
			CustomNetTables:SetTableValue("butt_settings", "slot_preset_" .. slot, data)
        end
    end)
end



function BUTTINGS.ALTERNATIVE_XP_TABLE()	-- xp values if MAX_LEVEL is different than 30
	local ALTERNATIVE_XP_TABLE = {		
		0,
		230,
		600,
		1080,
		1660,
		2260,
		2980,
		3730,
		4510,
		5320,
		6160,
		7030,
		7930,
		9155,
		10405,
		11680,
		12980,
		14305,
		15805,
		17395,
		18995,
		20845,
		22945,
		25295,
		27895,
		31395,
		35895,
		41395,
		47895,
		55395,
	} for i = #ALTERNATIVE_XP_TABLE + 1, BUTTINGS.DOTA_MECHANIC_OPTIONS.MAX_LEVEL.VALUE do ALTERNATIVE_XP_TABLE[i] = ALTERNATIVE_XP_TABLE[i - 1] + (300 * ( i - 15 )) end
	return ALTERNATIVE_XP_TABLE
end
