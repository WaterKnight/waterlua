local t = {}

local function create(path)
	assert(path, 'configParser: no path passed')

	path = io.toAbsPath(path, io.local_dir(1))

	local f = io.open(path, 'r')

	assert(f, 'configParser: cannot open file '..tostring(path))

	local t = {}

	for line in f:lines() do
		local pos, posEnd = line:find('=')

		if pos then
			t[line:sub(1, pos - 1)] = line:sub(posEnd + 1, line:len())
		end
	end

	f:close()

	return t
end

t.create = create

local globalPaths = {}

local function getGlobalPath(key)
	assert(key, 'key not set')

	return globalPaths[key]
end

t.getGlobalPath = getGlobalPath

local function setGlobalPath(key, val)
	assert(key, 'no key')
	assert(val, 'no value')

	assert((globalPaths[key] == nil), 'key '..tostring(key)..' already used')

	globalPaths[key] = val
end

t.setGlobalPath = setGlobalPath

configParser = t