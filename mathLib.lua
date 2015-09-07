--math.log10 = function(x)
--	return math.log(x, 10)
--end

math.QUARTER_ANGLE = 1.57

math.cutFloat = function(a, decPlaces)
	if (decPlaces == nil) then
		decPlaces = 2
	end

	local factor = math.pow(10, decPlaces)

	return (math.floor(a * factor) / factor)
end

function isInt(val)
	if (type(val) ~= 'number') then
		return false
	end

	return (math.floor(val) == val)
end

math.isInt = function(val)
	return isInt(val)
end

function hex2dec(val)
	assert(val, 'no val')

	return tonumber(val, 16)
end

function dec2hex(val, places)
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

function countDigits(val)
	assert(val, 'no value')

	return math.floor(math.log10(val))
end

function setDigits(val, digits)
	assert(val, 'no value')
	assert(digits, 'no digits')

	return string.rep('0', digits - countDigits(val))..val
end

local pow2Table = {}

for i = -256, 256, 1 do
	pow2Table[i] = math.pow(2, i)
end	

function pow2(i)
	return pow2Table[i]
end

local pow256Table = {}

for i = 0, 4, 1 do
	pow256Table[i] = math.pow(256, i)
end	

function pow256(i)
	return pow256Table[i]
end

