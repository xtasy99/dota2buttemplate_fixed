
function _G.softRequire(file)
	_G.dummyEnt = dummyEnt or Entities:CreateByClassname("info_target")
	local happy,msg = pcall(require,file)
	if not happy then
		dummyEnt:SetThink(function()
			error(msg,2)
		end)
	end
end

-------------------------- MATH FUNCTIONS -----------------------------

function math.clamp(val,min,max)
	if "number"~=type(val) or "number"~=type(min) or "number"~=type(max) then error("math.clamp:  args #1, #2 #3 must be numbers",2) end
	if min>max then min,max = max,min end
	if val>=max then return max end
	if val<=min then return min end
	return val
end

-------------------------- TABLE FUNCTIONS -----------------------------

function table.compare(table1, table2)
	if "table"~=type(table1) then error("1st argument of table.compare() is not a table",2) end
	if "table"~=type(table2) then error("2nd argument of table.compare() is not a table",2) end

	for k, v1 in pairs(table1) do
		local v2 = table2[k]
		if "table"==type(v1) and "table"==type(v2) then
			if not table.compare(v1,v2) then return false end
		else
			if v1~=v2 then return false end
		end
	end
	for k, _ in pairs(table2) do
		local v1 = table1[k]
		if v1==nil then return false end
	end

	return true
end

_G.TABLE_COMPARE_STRICT = 0
_G.TABLE_COMPARE_IGNORE_KEYS = 1
_G.TABLE_COMPARE_IGNORE_KEYS_AND_DUPLICATES = 2

-- not tested yet. careful.

function table.compare_dev(table1, table2, flags)
	if "table"~=type(table1) then error("1st argument of table.compare() is not a table",2) end
	if "table"~=type(table2) then error("2nd argument of table.compare() is not a table",2) end
	if nil==flags or TABLE_COMPARE_STRICT==flags then
		for k, v1 in pairs(table1) do
			local v2 = table2[k]
			if "table"==type(v1) and "table"==type(v2) then
				if not table.compare(v1,v2) then return false end
			else
				if v1~=v2 then return false end
			end
		end
		for k, _ in pairs(table2) do
			local v1 = table1[k]
			if v1==nil then return false end
		end
	elseif TABLE_COMPARE_IGNORE_KEYS==flags then
		local arr1 = {}
		for _, v1 in pairs(table1) do
			table.insert(arr1,v1)
		end
		-- arr1 is array with all table1 values
		for _, v2 in pairs(table2) do
			--checking every table2 value
			local foundV1 = false
			for k1, v1 in pairs(arr1) do
				if v2==v1
				or "table"==type(v1) and "table"==type(v2) and table.compare(v1,v2, flags)
				then
					-- found the counterpart in arr1
					foundV1 = true
					arr1[k1] = nil
					break
				end
			end
			if not foundV1 then
				-- no arr1 counterpart found
				return false
			end
		end
		for _ in pairs(arr1) do
			--  arr1 value is left with no table2 counterpart
			return false
		end
	elseif TABLE_COMPARE_IGNORE_KEYS_AND_DUPLICATES==flags then
		local values = {}
		local tabValues1 = {}
		for _, v1 in pairs(table1) do
			if "table"==type(v1) then
				-- v1 is a table
				local tableAlreadyListed = false
				for v0 in pairs(tabValues1) do
					if table.compare(v1,v0,flags) then
						tableAlreadyListed = true
						break
					end
				end
				if not tableAlreadyListed then
					tabValues1[v1] = v1
					values[v1] = 1
				end
			else
				-- v1 is a normal value, not table
				values[v1] = 1
			end
		end
		-- so now all table1 values are stored as keys in values	{12 = 1, "1a5" = 1,...}
		-- also tabValues1 contains all different tables 			{table51 = table51, table32 = table32, ...}
		-- for every tabValue1 there is an entry in values 			{..., "1a5" = 1, table51 = 1, ...}
		for k2, v2 in pairs(table2) do
			if "table"==type(v2) then
				local foundV1 = false
				for v1 in pairs(tabValues1) do
					if table.compare(v1,v2,flags) then
						foundV1 = true
						values[v1] = 2
						break
					end
				end
				if not foundV1 then return false end
			else
				-- v2 is a normal value, not table
				if nil==values[v2] then
					-- lonely value2
					return false
				end
				values[v2] = 2
			end
		end
		-- now all 1 inside values should have turned into 2
		-- values[normal values] == 2 now if they appeared in the 2nd table
		-- values[tables] == 2 if there was a similar (sub)table in table2
		for k,v in pairs(values) do
			if 1==v then
				-- lonely value1
				return false
			end
		end
	end
	return true
end


function table.merge(weak, strong)
	if (type(weak) ~= "table") then error("1st argument of table.merge() is not a table",2) end
	if (type(strong) == "table") then
		for k,v in pairs(strong) do
			if type(v)=="table" then
				if (type(weak[k])~="table") then weak[k] = {} end
				table.merge(weak[k],v)
				if next(weak[k])==nil then weak[k] = nil end
			else
				weak[k] = v
			end
		end
	end
	return weak
end

function table.copy(tabel)
	if ("table"~=type(tabel)) then error("Argument of table.copy() is not a table",2) end
	local out = {}
	for k,v in pairs(tabel) do
		out[k]=v
	end
	return out
end

function table.length(t)
	if ("table"~=type(t)) then error("Argument of table.length() is not a table",2) end
	local len = 0
	for _,_ in pairs(t) do
		len = len + 1
	end
	return len
end

-------------------------- FILE COPY FUNCTIONS -------------------------

function copyFile(fromFile, toFile)
	if not io then return false end
	local replacingFile = io.open(toFile, "rb")
	if replacingFile then
		local replacingSize = replacingFile:seek("end")
		replacingFile:close()
	end

	local infile = io.open(fromFile, "rb")
	local fromSize = infile:seek("end")
	if replacingSize==fromSize then infile:close() return false end
	instr = infile:read("*a")
	infile:close()

	local outfile = io.open(toFile, "wb")
	outfile:write(instr)
	outfile:close()
	return true
end

function strToFile(str, filename)
	if not io then return false end
	local file = io.open(filename,"w")
	file:write(str)
	io.close(file)
	return true
end

function kvToFile(kv, filename)
	strToFile(kvToString(kv,""),filename)
end

function fileToString(filename)
	if not io then return nil end
	local file = io.open(filename, "r")
	local out = file:read("*all")
	io.close(file)
	return out
end

function kvToString(kv,prefix)
	local out = ""
	if type(kv)=="table" then
		for k,v in opairs(kv) do
			if type(v)=="table" then
				out = ("%s%s\"%s\"\n%s{\n%s%s}\n"):format(out,prefix,k,prefix,kvToString(v,prefix.."\t"),prefix)
				-- out = out .. prefix .. "\"" .. k .. "\" " .. "\n".. prefix .."{\n" .. kvToString(v,prefix.."\t") .. prefix .. "}\n"
			else
				local val = (type(v)=="string" or type(v)=="number") and v or "ERR"
				out = ("%s%s\"%-32s \"%s\"\n"):format(out,prefix,(k .. "\""),val)
			end
		end
	end
	return out
end

function fileToTable(filename)
	return fixParsedTable(LoadKeyValues(filename))
end

function fixParsedTable( tabl )
	if "table"~=type(tabl) then return tabl end
	for k,v in pairs(tabl) do
		if "number"==type(v) then
			tabl[k] = 0.001 * math.floor(v*1000+0.5)
		else tabl[k] = fixParsedTable(tabl[k]) end
	end
	return tabl
end

function globalsToString()
	local out = ""
	for k,v in pairs(_G) do
		if type(v)=="function" then v = "f()" end
		if type(v)=="table" then v = "{}" end
		if type(v)=="userdata" then v = "udat" end
		if type(v)=="boolean" then v = V and "true" or "false" end
		out = out .. k .. ": " .. v .. "\n"
	end
	return out
end

-------------------------- BAREBONES STUFF -------------------------

function DebugPrint(...)
	local spew = Convars:GetInt('barebones_spew') or -1
	if spew == -1 and BAREBONES_DEBUG_SPEW then
		spew = 1
	end

	if spew == 1 then
		print(...)
	end
end

function DebugPrintTable(...)
	local spew = Convars:GetInt('barebones_spew') or -1
	if spew == -1 and BAREBONES_DEBUG_SPEW then
		spew = 1
	end

	if spew == 1 then
		PrintTable(...)
	end
end

function PrintTable(t, indent, done)
	--print ( string.format ('PrintTable type %s', type(keys)) )
	if type(t) ~= "table" then return end

	done = done or {}
	done[t] = true
	indent = indent or 0

	local l = {}
	for k, v in pairs(t) do
		table.insert(l, k)
	end

	table.sort(l)
	for k, v in ipairs(l) do
		-- Ignore FDesc
		if v ~= 'FDesc' then
			local value = t[v]

			if type(value) == "table" and not done[value] then
				done [value] = true
				print(string.rep ("\t", indent)..tostring(v)..":")
				PrintTable (value, indent + 2, done)
			elseif type(value) == "userdata" and not done[value] then
				done [value] = true
				print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
				PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
			else
				if t.FDesc and t.FDesc[v] then
					print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
				else
					print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
				end
			end
		end
	end
end

-- Colors
COLOR_NONE = '\x06'
COLOR_GRAY = '\x06'
COLOR_GREY = '\x06'
COLOR_GREEN = '\x0C'
COLOR_DPURPLE = '\x0D'
COLOR_SPINK = '\x0E'
COLOR_DYELLOW = '\x10'
COLOR_PINK = '\x11'
COLOR_RED = '\x12'
COLOR_LGREEN = '\x15'
COLOR_BLUE = '\x16'
COLOR_DGREEN = '\x18'
COLOR_SBLUE = '\x19'
COLOR_PURPLE = '\x1A'
COLOR_ORANGE = '\x1B'
COLOR_LRED = '\x1C'
COLOR_GOLD = '\x1D'


--[[Author: Noya
	Date: 09.08.2015.
	Hides all dem hats
	]]
	function HideWearables( event )
		local hero = event.caster
		local ability = event.ability

		hero.hiddenWearables = {} -- Keep every wearable handle in a table to show them later
		local model = hero:FirstMoveChild()
		while model ~= nil do
			if model:GetClassname() == "dota_item_wearable" then
				model:AddEffects(EF_NODRAW) -- Set model hidden
				table.insert(hero.hiddenWearables, model)
			end
			model = model:NextMovePeer()
		end
	end

	function ShowWearables( event )
		local hero = event.caster

		for i,v in pairs(hero.hiddenWearables) do
			v:RemoveEffects(EF_NODRAW)
		end
	end
	
function opairs(t)
	function orderedNext(t, state)
		function __genOrderedIndex( t )
		    local orderedIndex = {}
		    for key in pairs(t) do
		        table.insert( orderedIndex, key )
		    end
		    table.sort( orderedIndex )
		    return orderedIndex
		end

	    -- Equivalent of the next function, but returns the keys in the alphabetic
	    -- order. We use a temporary ordered key table that is stored in the
	    -- table being iterated.

	    local key = nil
	    --print("orderedNext: state = "..tostring(state) )
	    if state == nil then
	        -- the first time, generate the index
	        t.__orderedIndex = __genOrderedIndex( t )
	        key = t.__orderedIndex[1]
	    else
	        -- fetch the next value
	        for i = 1,table.getn(t.__orderedIndex) do
	            if t.__orderedIndex[i] == state then
	                key = t.__orderedIndex[i+1]
	            end
	        end
	    end

	    if key then
	        return key, t[key]
	    end

	    -- no more value to return, cleanup
	    t.__orderedIndex = nil
	    return
	end
    -- Equivalent of the pairs() function on tables. Allows to iterate
    -- in order
    return orderedNext, t, nil
end