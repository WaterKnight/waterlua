local t = {}

local function log10(x)
	return math.log(x, 10)
end

--t.log10 = log10

local QUARTER_ANGLE = 1.57

t.QUARTER_ANGLE = QUARTER_ANGLE

local function cutFloat(a, decPlaces)
	if (decPlaces == nil) then
		decPlaces = 2
	end

	local factor = math.pow(10, decPlaces)

	return (math.floor(a * factor) / factor)
end

t.cutFloat = cutFloat

local function isInt(val)
	if (type(val) ~= 'number') then
		return false
	end

	return (math.floor(val) == val)
end

t.isInt = isInt

local function hex2dec(val)
	assert(val, 'no val')

	return tonumber(val, 16)
end

t.hex2dec = hex2dec

local function dec2hex(val, places)
	assert(val, 'no val')

	if (places == nil) then
		places = 0
	end

	local res = string.format("%X", val)

	if (res:len() < places) then
		res = string.format('%s%s', string.rep('0', places - res:len()), res)
	end

	return res
end

t.dec2hex = dec2hex

local function countDigits(val)
	assert(val, 'no value')

	return math.floor(math.log10(val))
end

t.countDigits = countDigits

local function setDigits(val, digits)
	assert(val, 'no value')
	assert(digits, 'no digits')

	return string.rep('0', digits - countDigits(val))..val
end

t.setDigits = setDigits

local pow2Table = {}

for i = -256, 256, 1 do
	pow2Table[i] = math.pow(2, i)
end	

local function pow2(i)
	return pow2Table[i]
end

t.pow2 = pow2

local pow256Table = {}

for i = 0, 4, 1 do
	pow256Table[i] = math.pow(256, i)
end	

local function pow256(i)
	return pow256Table[i]
end

t.pow256 = pow256

moduleLib.expose('math', t)