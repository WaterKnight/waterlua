local packagePath = package.path
local packageCPath = package.cpath

local localDir = debug.getinfo(1, 'S').source:sub(2):match('(.*'..'\\'..')')

package.path = localDir..'?.lua'..';'..packagePath
package.cpath = localDir..'?.dll'..';'..packageCPath

require 'bit'
require 'rings'

local t = {}

function expose(name, val)
	local base = _G[name]

	if (base == nil) then
		_G[name] = val
	else
		for k, v in pairs(val) do
			base[k] = v
		end
	end
end

t.expose = expose

expose('moduleLib', t)

require 'orient'

require 'localio'

require 'configParser'
require 'dataStructures'
require 'mathLib'
require 'osLib'
require 'stringLib'
require 'tableLib'

package.path = packagePath
package.cpath = packageCPath

package.cpath = package.cpath..';'..localDir..'luaSocket\\?.dll'
package.path = package.path..';'..localDir..'luaSocket\\?.lua'

package.cpath = package.cpath..';'..localDir..'luaSocket\\lua\\?.dll'
package.path = package.path..';'..localDir..'luaSocket\\lua\\?.lua'

--error(package.path)