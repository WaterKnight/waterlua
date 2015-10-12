local t = {}

local function create()
	local this = {}

	this.assignments = {}
	this.sections = {}

	function this:readFromFile(path, ignoreNotFound)
		assert(path, 'configParser: no path passed')

		local f = io.open(path, 'r')

		if (f == nil) then
			if not ignoreNotFound then
				error(string.format('configParser: cannot open file %s', tostring(path)))
			else
				return false
			end
		end

		local curSection = nil

		for line in f:lines() do
			local sectionName = line:match('%['..'([%w%d%p_]*)'..'%]')

			if (sectionName ~= nil) then
				curSection = this.sections[sectionName]

				if (curSection == nil) then
					curSection = {}

					this.sections[sectionName] = curSection

					curSection.assignments = {}
					curSection.lines = {}
				end
			elseif (curSection ~= nil) then
				curSection.lines[#curSection.lines + 1] = line
			end

			local pos, posEnd = line:find('=')

			if pos then
				local name = line:sub(1, pos - 1)
				local val = line:sub(posEnd + 1, line:len())

				if ((type(val) == 'string')) then
					val = val:match('\"(.*)\"') or val
				end

				if (curSection ~= nil) then
					curSection.assignments[name] = val
				else
					this.assignments[name] = val
				end
			end
		end

		f:close()

		return true
	end

	function this:merge(other)
		assert(other, 'no other')

		for name, val in pairs(other.assignments) do
			this.assignments[name] = val
		end

		for name, otherSection in pairs(other.sections) do
			local section = this.sections[name]

			if (section == nil) then
				section = {}

				this.sections[name] = section
			end

			for name, val in pairs(otherSection.assignments) do
				section.assignments[name] = val
			end
		end
	end

	return this
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

expose('configParser', t)