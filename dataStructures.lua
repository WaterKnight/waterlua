local t = {}

t.createList = function()
	local this = {}

	this.head = nil
	this.tail = nil

	this.members = {}
	this.memberIs = {}
	this.memberNext = {}
	this.memberPrev = {}
	this.memberVal = {}
	this.size = 0

	function this:contains(val)
		return this.memberIs[val]
	end

	function this:containsKey(key)
		return this.members[key]
	end

	function this:getFromIndex(index)
		assert(index, 'no index')

		assert((index > 0) and (index <= this.size), 'index '..tostring(index)..' out of bounds '..'1..'..this.size)

		local member = this.head

		while (index > 1) do
			member = this.memberNext[member]

			index = index - 1
		end

		return member
	end

	function this:getIndex(key)
		assert(this:containsKey(key), 'key '..tostring(key)..' not available')

		local i = 1

		for key2 in this:iter() do
			if (key2 == key) then
				return i
			end

			i = i + 1
		end
	end

	function this:getVal(key)
		return this.memberVal[key]
	end

	function this:setVal(key, val)
		assert(this.containsKey(key), 'key '..tostring(key)..' not available')

		this.memberVal[key] = val
	end

	function this:add(val, key)
		assert(val, 'no val')

		assert(not this:contains(val), 'already contains '..tostring(val))

		key = key or val

		local prev = this.tail

		if (prev ~= nil) then
			this.memberNext[prev] = key
			this.memberPrev[key] = prev
		end

		if (this.head == nil) then
			this.head = key
		end

		this.tail = key

		this.members[key] = true
		this.memberVal[key] = val
		this.memberIs[val] = true
		this.size = this.size + 1
	end

	function this:addAt(val, index, key)
		assert(val, 'no val')

		assert(not this:contains(val), 'already contains '..tostring(val))

		key = key or val

		if (index == nil) then
			this:add(val, key)

			return
		end

		assert((index > 0) and (index - 1 <= this.size), 'index '..tostring(index)..' out of bounds '..'1..'..(this.size + 1))

		local prev
		local next

		if (index > 1) then
			prev = this:getFromIndex(index - 1)
		end
		if (index <= this.size) then
			next = this:getFromIndex(index)
		end

		if (prev == nil) then
			this.head = key
		else
			this.memberNext[prev] = key
			this.memberPrev[key] = prev
		end

		if (next == nil) then
			this.tail = key
		else
			this.memberPrev[next] = key
			this.memberNext[key] = next
		end

		this.members[key] = true
		this.memberVal[key] = val
		this.memberIs[val] = true
		this.size = this.size + 1
	end

	function this:removeByKey(key)
		assert(key, 'no key')

		assert(this:containsKey(key), 'key '..tostring(key)..' not available')

		local prev = this.memberPrev[key]
		local next = this.memberNext[key]

		if (prev ~= nil) then
			this.memberNext[prev] = next
		end
		if (next ~= nil) then
			this.memberPrev[next] = prev
		end

		if (this.head == key) then
			this.head = next
		end
		if (this.tail == key) then
			this.tail = prev
		end

		this.memberIs[this.memberVal[key]] = nil

		this.members[key] = nil
		this.memberVal[key] = nil
		this.size = this.size - 1
	end

	function this:removeByIndex(index)
		this:removeByKey(this:getFromIndex(index))
	end

	function this:iter()
		local key = this.head

		return function()
			if (key ~= nil) then
				local resultKey = key

				key = this.memberNext[key]

				return resultKey, this.memberVal[resultKey]
			end
		end
	end

	function this:print()
		local t = {}

		for key, val in this:iter() do
			t[#t + 1] = val
		end

		print(table.concat(t, ';'))
	end

	return this
end

dataStructures = t