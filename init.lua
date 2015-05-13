local packagePath = package.path
local packageCPath = package.cpath

local localDir = debug.getinfo(1, 'S').source:sub(2):match('(.*'..'\\'..')')

package.path = localDir..'?.lua'..';'..packagePath
package.cpath = localDir..'?.dll'..';'..packageCPath

require 'bit'
require 'rings'


require 'localio'

require 'configParser'
require 'mathLib'
require 'osLib'
require 'stringLib'
require 'tableLib'

package.path = packagePath
package.cpath = packageCPath