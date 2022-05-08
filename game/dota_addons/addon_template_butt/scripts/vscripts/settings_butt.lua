BUTTINGS = {
}

function ReadKv()
	local file = LoadKeyValues('scripts/kv/settings.kv')
	if file == nil or not next(file) then
		print("empty settings :/")
		return
	end
	BUTTINGS = file
end

ReadKv()

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
