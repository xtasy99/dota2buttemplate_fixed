--- base64.lua
--
-- V0.3 for Lua 5.1
--
-- A full description of the specification can be found here: http://tools.ietf.org/html/rfc4648
--
-- To encode, use base64.encode(input), where input is a string of arbitrary bytes.  The output is a Base64 encoded string.
-- To decode, use base64.decode(input), where input is a Base64 encoded string.  The output is a string of arbitrary bytes.
--
-- The library will throw an error on invalid input, you can catch these as such:
--
-- local status, result = pcall(base64.decode(invalidInput))
-- if not status then
--     print("Error, "..result)
-- end
--
-- If you prefer a different Base64 variant, you can simply change the ENCODABET to your liking.
--
-- For all valid input, input == base64.decode(base64.encode(input)).
--
-- This library has a dependency on LuaBit v0.4, which can be found here: http://luaforge.net/projects/bit/
--
-- Copyright (C) 2012 by Paul Moore
-- Copyright (C) 2012 by Matthew Murdoch
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.

base64 = {}

--- octet -> char encoding.
local ENCODABET = {
	'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
	'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
	'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd',
	'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
	'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x',
	'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7',
	'8', '9', '+', '/'
}

--- char -> octet encoding.
local DECODABET = {}
for i, v in ipairs(ENCODABET) do
	DECODABET[v] = i - 1
end

local PAD = "="

--- Converts a 6-bit octet into the associated Base64 character.
--
-- @param octet A 6-bit integer.
-- @return The Base64 representation of the character
local function toChar (octet)
	return ENCODABET[octet + 1]
end

--- Converts a Base64 character into the associated octet.
--
-- @param char The single Base64 character.
-- @return The 6-bit integer representing the Base64 character.
local function toOctet (char)
	return DECODABET[char]
end

--- Encodes a string into a Base64 string.
-- The input can be any string of arbitrary bytes.
-- If the input is not a string, or the string is empty, an error will be thrown.
--
-- @param input A non-empty input string.
-- @return The Base64 representation of the input string.
function base64.encode (input)

	local bytes = { input:byte(i, #input) }

	local out = {}
	
	-- Go through each triplet of 3 bytes, which produce 4 octets.
	local i = 1
	while i <= #bytes - 2 do
		local buffer = 0
		
		-- Fill the buffer with the bytes, producing a 24-bit integer.
		local b = bit.blshift(bytes[i], 16)
		b = bit.band(b, 0xff0000)
		buffer = bit.bor(buffer, b)
		
		b = bit.blshift(bytes[i + 1], 8)
		b = bit.band(b, 0xff00)
		buffer = bit.bor(buffer, b)
		
		b = bit.band(bytes[i + 2], 0xff)
		buffer = bit.bor(buffer, b)
		
		-- Read out the 4 octets into the output buffer.
		b = bit.blogic_rshift(buffer, 18)
		b = bit.band(b, 0x3f)
		out[#out + 1] = toChar(b)
		
		b = bit.blogic_rshift(buffer, 12)
		b = bit.band(b, 0x3f)
		out[#out + 1] = toChar(b)
		
		b = bit.blogic_rshift(buffer, 6)
		b = bit.band(b, 0x3f)
		out[#out + 1] = toChar(b)
		
		b = bit.band(buffer, 0x3f)
		out[#out + 1] = toChar(b)
				
		i = i + 3
	end
	
	-- Special case 1: One byte extra, will produce 2 octets.
	if #bytes % 3 == 1 then
		local buffer = bit.blshift(bytes[i], 16)
		buffer = bit.band(buffer, 0xff0000)
		
		local b = bit.blogic_rshift(buffer, 18)
		b = bit.band(b, 0x3f)
		out[#out + 1] = toChar(b)
		
		b = bit.blogic_rshift(buffer, 12)
		b = bit.band(b, 0x3f)
		out[#out + 1] = toChar(b)
		
		out[#out + 1] = PAD
		out[#out + 1] = PAD
		
	-- Special case 2: Two bytes extra, will produce 3 octets.
	elseif #bytes % 3 == 2 then
		local buffer = 0
		
		local b = bit.blshift(bytes[i], 16)
		b = bit.band(b, 0xff0000)
		buffer = bit.bor(buffer, b)
		
		b = bit.blshift(bytes[i + 1], 8)
		b = bit.band(b, 0xff00)
		buffer = bit.bor(buffer, b)

		b = bit.blogic_rshift(buffer, 18)
		b = bit.band(b, 0x3f)
		out[#out + 1] = toChar(b)
		
		b = bit.blogic_rshift(buffer, 12)
		b = bit.band(b, 0x3f)
		out[#out + 1] = toChar(b)
		
		b = bit.blogic_rshift(buffer, 6)
		b = bit.band(b, 0x3f)
		out[#out + 1] = toChar(b)
		
		out[#out + 1] = PAD
	end
	
	return table.concat(out)
	
end

--- Decodes a Base64 string into an output string of arbitrary bytes.
-- If the input is not a string, or the string is empty, or the string is not well-formed Base64, an error will be thrown.
--
-- @param input The Base64 input to decode.
-- @return The decoded Base64 string, as a string of bytes.
function base64.decode (input)
	
	local length = #input
	-- Ignore any padding.
	if PAD then
		length = input:find(PAD, 1, true) or (length + 1)
		length = length - 1
	end
	assert(length > 0, "Invalid input, cannot decode a padded string with no bytes: "..tostring(input))
	
	local out = {}
	
	-- Go through each group of 4 octets to obtain 3 bytes.
	local i = 1
	while i <= length - 3 do
		local buffer = 0
		
		-- Read the 4 octets into the buffer, producing a 24-bit integer.
		local b = toOctet(input:sub(i, i))
		b = bit.blshift(b, 18)
		buffer = bit.bor(buffer, b)
		i = i + 1
		
		b = toOctet(input:sub(i, i))
		b = bit.blshift(b, 12)
		buffer = bit.bor(buffer, b)
		i = i + 1
		
		b = toOctet(input:sub(i, i))
		b = bit.blshift(b, 6)
		buffer = bit.bor(buffer, b)
		i = i + 1
		
		b = toOctet(input:sub(i, i))
		buffer = bit.bor(buffer, b)
		i = i + 1
		
		-- Append the 3 re-constructed bytes into the output buffer.
		b = bit.blogic_rshift(buffer, 16)
		b = bit.band(b, 0xff)
		out[#out + 1] = b
		
		b = bit.blogic_rshift(buffer, 8)
		b = bit.band(b, 0xff)
		out[#out + 1] = b
		
		b = bit.band(buffer, 0xff)
		out[#out + 1] = b
	end

	-- Special case 1: Only 2 octets remain, producing 1 byte.
	if length % 4 == 2 then
		local buffer = 0

		local b = toOctet(input:sub(i, i))
		b = bit.blshift(b, 18)
		buffer = bit.bor(buffer, b)
		i = i + 1
		
		b = toOctet(input:sub(i, i))
		b = bit.blshift(b, 12)
		buffer = bit.bor(buffer, b)
		i = i + 1
		
		b = bit.blogic_rshift(buffer, 16)
		b = bit.band(b, 0xff)
		out[#out + 1] = b
		
	-- Special case 2: Only 3 octets remain, producing 2 bytes.
	elseif length % 4 == 3 then
		local buffer = 0
		
		local b = toOctet(input:sub(i, i))
		b = bit.blshift(b, 18)
		buffer = bit.bor(buffer, b)
		i = i + 1
		
		b = toOctet(input:sub(i, i))
		b = bit.blshift(b, 12)
		buffer = bit.bor(buffer, b)
		i = i + 1
		
		b = toOctet(input:sub(i, i))
		b = bit.blshift(b, 6)
		buffer = bit.bor(buffer, b)
		i = i + 1

		b = bit.blogic_rshift(buffer, 16)
		b = bit.band(b, 0xff)
		out[#out + 1] = b
		
		b = bit.blogic_rshift(buffer, 8)
		b = bit.band(b, 0xff)
		out[#out + 1] = b
		
	-- Special case 3: One octet remains, we can't get any bytes out of this, throw error.
	elseif length % 4 == 1 then
		error("Invalid length input string, extra character: "..tostring(input:sub(i, i)))
	end

	return string.char(unpack(out))
	
end

--[[---------------
LuaBit v0.4
-------------------
a bitwise operation lib for lua.

http://luaforge.net/projects/bit/

How to use:
-------------------
 bit.bnot(n) -- bitwise not (~n)
 bit.band(m, n) -- bitwise and (m & n)
 bit.bor(m, n) -- bitwise or (m | n)
 bit.bxor(m, n) -- bitwise xor (m ^ n)
 bit.brshift(n, bits) -- right shift (n >> bits)
 bit.blshift(n, bits) -- left shift (n << bits)
 bit.blogic_rshift(n, bits) -- logic right shift(zero fill >>>)
 
Please note that bit.brshift and bit.blshift only support number within
32 bits.

2 utility functions are provided too:
 bit.tobits(n) -- convert n into a bit table(which is a 1/0 sequence)
               -- high bits first
 bit.tonumb(bit_tbl) -- convert a bit table into a number 
-------------------

Under the MIT license.

copyright(c) 2006~2007 hanzhao (abrash_han@hotmail.com)
--]]---------------

do

------------------------
-- bit lib implementions

local function check_int(n)
 -- checking not float
 if(n - math.floor(n) > 0) then
  error("trying to use bitwise operation on non-integer!")
 end
end

local function to_bits(n)
 check_int(n)
 if(n < 0) then
  -- negative
  return to_bits(bit.bnot(math.abs(n)) + 1)
 end
 -- to bits table
 local tbl = {}
 local cnt = 1
 while (n > 0) do
  local last = math.mod(n,2)
  if(last == 1) then
   tbl[cnt] = 1
  else
   tbl[cnt] = 0
  end
  n = (n-last)/2
  cnt = cnt + 1
 end

 return tbl
end

local function tbl_to_number(tbl)
 local n = table.getn(tbl)

 local rslt = 0
 local power = 1
 for i = 1, n do
  rslt = rslt + tbl[i]*power
  power = power*2
 end
 
 return rslt
end

local function expand(tbl_m, tbl_n)
 local big = {}
 local small = {}
 if(table.getn(tbl_m) > table.getn(tbl_n)) then
  big = tbl_m
  small = tbl_n
 else
  big = tbl_n
  small = tbl_m
 end
 -- expand small
 for i = table.getn(small) + 1, table.getn(big) do
  small[i] = 0
 end

end

local function bit_or(m, n)
 local tbl_m = to_bits(m)
 local tbl_n = to_bits(n)
 expand(tbl_m, tbl_n)

 local tbl = {}
 local rslt = math.max(table.getn(tbl_m), table.getn(tbl_n))
 for i = 1, rslt do
  if(tbl_m[i]== 0 and tbl_n[i] == 0) then
   tbl[i] = 0
  else
   tbl[i] = 1
  end
 end
 
 return tbl_to_number(tbl)
end

local function bit_and(m, n)
 local tbl_m = to_bits(m)
 local tbl_n = to_bits(n)
 expand(tbl_m, tbl_n) 

 local tbl = {}
 local rslt = math.max(table.getn(tbl_m), table.getn(tbl_n))
 for i = 1, rslt do
  if(tbl_m[i]== 0 or tbl_n[i] == 0) then
   tbl[i] = 0
  else
   tbl[i] = 1
  end
 end

 return tbl_to_number(tbl)
end

local function bit_not(n)
 
 local tbl = to_bits(n)
 local size = math.max(table.getn(tbl), 32)
 for i = 1, size do
  if(tbl[i] == 1) then 
   tbl[i] = 0
  else
   tbl[i] = 1
  end
 end
 return tbl_to_number(tbl)
end

local function bit_xor(m, n)
 local tbl_m = to_bits(m)
 local tbl_n = to_bits(n)
 expand(tbl_m, tbl_n) 

 local tbl = {}
 local rslt = math.max(table.getn(tbl_m), table.getn(tbl_n))
 for i = 1, rslt do
  if(tbl_m[i] ~= tbl_n[i]) then
   tbl[i] = 1
  else
   tbl[i] = 0
  end
 end
 
 --table.foreach(tbl, print)

 return tbl_to_number(tbl)
end

local function bit_rshift(n, bits)
 check_int(n)
 
 local high_bit = 0
 if(n < 0) then
  -- negative
  n = bit_not(math.abs(n)) + 1
  high_bit = 2147483648 -- 0x80000000
 end

 for i=1, bits do
  n = n/2
  n = bit_or(math.floor(n), high_bit)
 end
 return math.floor(n)
end

-- logic rightshift assures zero filling shift
local function bit_logic_rshift(n, bits)
 check_int(n)
 if(n < 0) then
  -- negative
  n = bit_not(math.abs(n)) + 1
 end
 for i=1, bits do
  n = n/2
 end
 return math.floor(n)
end

local function bit_lshift(n, bits)
 check_int(n)
 
 if(n < 0) then
  -- negative
  n = bit_not(math.abs(n)) + 1
 end

 for i=1, bits do
  n = n*2
 end
 return bit_and(n, 4294967295) -- 0xFFFFFFFF
end

local function bit_xor2(m, n)
 local rhs = bit_or(bit_not(m), bit_not(n))
 local lhs = bit_or(m, n)
 local rslt = bit_and(lhs, rhs)
 return rslt
end

--------------------
-- bit lib interface

bit = {
 -- bit operations
 bnot = bit_not,
 band = bit_and,
 bor  = bit_or,
 bxor = bit_xor,
 brshift = bit_rshift,
 blshift = bit_lshift,
 bxor2 = bit_xor2,
 blogic_rshift = bit_logic_rshift,

 -- utility func
 tobits = to_bits,
 tonumb = tbl_to_number,
}

end

--[[
for i = 1, 100 do
 for j = 1, 100 do
  if(bit.bxor(i, j) ~= bit.bxor2(i, j)) then
   error("bit.xor failed.")
  end
 end
end
--]]

return base64