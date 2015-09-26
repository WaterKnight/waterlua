local t = {}

local function create(t)
	if (t == nil) then
		return nil
	end

	if (type(t) == 'table') then
		return t
	end

	return {t}
end

t.create = create
totable = create

local function toLua(t)
	local res = {}

	for k, v in pairs(t) do
		if (type(v) == 'table') then
			v = tableToLua(v)
		else
			if (type(v) == 'string') then
				v = string.format('%q', v)
			else
				v = tostring(v)
			end
		end

		if (type(k) == 'number') then
			res[#res + 1] = v
		else
			res[#res + 1] = k..'='..tostring(v)
		end
	end

	return '{'..table.concat(res, ', ')..'}'
end

t.toLua = toLua

local function contains(t, e)
	if (t == nil) then
		return false
	end

	for k, v in pairs(t) do
		if (v == e) then
			return true
		end
	end

	return false
end

t.contains = contains

local function getSize_nest(t, recursionTable)
	if (recursionTable[t] ~= nil) then
		return 0
	end

	local c = 0

	for k, val in pairs(t) do
		if (type(val) == 'table') then
			c = c + getTableSize_nest(val, recursionTable) + 1
		else
			c = c + 1
		end
	end

	return c
end

local function getSize(t, nested)
	assert(t, 'no arg')

	assert((type(t) == 'table'), 'no table')

	local recursionTable = {}

	recursionTable[t] = t

	local c = 0

	for k, val in pairs(t) do
		if (nested and (type(val) == 'table')) then
			c = c + getTableSize_nest(val, recursionTable) + 1
		else
			c = c + 1
		end
	end

	return c
end

t.getSize = getSize

local function copy_nest(source, recursionTable)
	if recursionTable[source] then
		return recursionTable[source]
	end

	local result = {}

	recursionTable[source] = result

	for k, v in pairs(source) do
		if (type(v) == "table") then
			local add = copy_nest(v, recursionTable)

			if (k == v) then
				k = add
			end

			result[k] = add
		else
			result[k] = v
		end
	end

	return result
end

local function copy(source)
	if (source == nil) then
		return nil
	end

	local result = {}
	local recursionTable = {}

	recursionTable[source] = result

	for k, v in pairs(source) do
		if (type(v) == "table") then
			local add = copy_nest(v, recursionTable)

			if (k == v) then
				k = add
			end

			result[k] = add
		else
			result[k] = v
		end
	end

	return result
end

t.copy = copy

local function merge(source, toAdd)
	for k, v in pairs(toAdd) do
		if v then
			if (type(v) == "table") then
				if (type(source[k]) ~= "table") then
					source[k] = {}
				end

				mergeTable(source[k], v)
			else
				source[k] = v
			end
		end
	end
end

t.merge = merge

io.local_require('stringLib')

local function printTable(t, nestDepth)
	nestDepth = nestDepth or 0

	for k, v in pairs(t) do
		if (type(v) == "table") then
			print(string.rep("\t", nestDepth).."//"..k)

			printTable(v, nestDepth + 1)
		else
			if (type(v) == "boolean") then
				v = boolToString(v)
			end

			print(string.rep("\t", nestDepth)..k.." --> "..tostring(v))
		end
	end
end

t.print = printTable

local function write(fileOrPath, root, nestDepth)
	assert(fileOrPath, 'no file/path')
	assert(root, 'no root')

	local file

	if (type(fileOrPath) == 'string') then
		file = io.open(fileOrPath, 'w+')

		assert(file, 'cannot open '..tostring(fileOrPath))
	else
		file = fileOrPath
	end

	local recursionTable = {}

	local function writeTable_nest(t, nestDepth)
		if recursionTable[t] then
			return
		end

		recursionTable[t] = t

		for k, v in pairs(t) do
			if (type(v) == "table") then
				writeTable_nest(v, nestDepth + 1)
			else
				file:write(tostring(v), '\n')
			end
		end
	end

	if (nestDepth == nil) then
		nestDepth = 0
	end

	writeTable_nest(root, nestDepth)

	if (type(fileOrPath) == 'string') then
		file:close()
	end
end

t.write = write

local function writeEx(fileOrPath, root, nestDepth)
	assert(fileOrPath, 'no file/path')
	assert(root, 'no root')

	local file

	if (type(fileOrPath) == 'string') then
		file = io.open(fileOrPath, 'w+')

		assert(file, 'cannot open '..tostring(fileOrPath))
	else
		file = fileOrPath
	end

	local recursionTable = {}

	file:write("contents of ", tostring(root), "\n")

	local function writeTable_nest(t, nestDepth)
		if recursionTable[t] then
			file:write("recursion ", tostring(t), "\n")

			return--error("writeTable: recursion in table")
		end

		recursionTable[t] = t

		for k, v in pairs(t) do
			if (type(v) == "table") then
				file:write(string.rep("\t", nestDepth).."//"..k.."\n")

				writeTable_nest(v, nestDepth + 1)
			else
				if (type(v) == "boolean") then
					v = boolToString(v)
				end

				file:write(string.rep("\t", nestDepth)..k.." --> "..tostring(v).."\n")
			end
		end
	end

	if (nestDepth == nil) then
		nestDepth = 0
	end

	writeTable_nest(root, nestDepth)

	if (type(fileOrPath) == 'string') then
		file:close()
	end
end

t.writeEx = writeEx

local function mix(t1, t2, sep)
	if (sep == nil) then
		sep = ""
	end

	local result = {}

	for i = 1, #t1, 1 do
		result[i] = t1[i]..t2[i]
	end

	return result
end

t.mix = mix

local function addToEnv(t)
	setmetatable(t, {__index = _G})
	setfenv(2, t)
end

t.addToEnv = addToEnv

for k, v in pairs(t) do
	table[k] = v
end