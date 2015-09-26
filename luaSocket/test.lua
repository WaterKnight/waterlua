package.path = '..\\..\\?\\init.lua'
package.cpath = '..\\..\\?\\init.dll'

require 'waterlua'

require 'socket.http'

require 'ltn12'

--local ftp = require 'socket.ftp'
require 'socket.url'

local t = {}

--local cmd = socket.url.parse("ftp://inwcfunmap:blubby7@inwcfunmap.bplaced.net/FA_01_11_2014/FA_01_11_2014_actionAos.w3g;type=i")

local function reqDir(dir)
	local cmd = socket.url.parse('ftp://inwcfunmap:blubby7@'..dir)

	cmd.command = "NLST"
	cmd.sink = ltn12.sink.table(t)

	print(ftp.get(cmd))

	t = table.concat(t):split('\n')

	for k, v in pairs(t) do
		local name = v:match('([%w%_%d]+[%.]*[%w%_%d]*)')

		if (name) then
			local path = dir..'/'..name

			print('load', path)
			local cmd = socket.url.parse(path)

			local t = {}

			cmd.type = 'i'
			cmd.sink = ltn12.sink.table(t)

			--print(ftp.get(cmd))

			local resp, stat, hdr = socket.http.request{
				url = 'http://'..path
			}

			print(stat)
		end
	end
end

--reqDir('inwcfunmap.bplaced.net/postproc')

function abc(...)
	print('hello', ...)
end

local tp = require 'socket.tp'

local u = socket.url.parse('ftp://inwcfunmap:blubby7@inwcfunmap.bplaced.net/postproc;type=i')

local f = tp.connect(u.host, 21)

f:greet()

f:login(u.user, u.password)

f:type('i')
f:pasv()
f:receive(u)
f:quit()
f:close()



--[[local cmd = socket.url.parse('ftp://ftp.tecgraf.puc-rio.br/pub/lua/lua.tar.gz')

cmd.sink = ltn12.sink.table(t)
cmd.type = 'i'

local f, e  = socket.ftp.get(cmd)

print(f, e)]]

--[[local resp, stat, hdr = socket.http.request{
  url     = "http://www.moonlightflower.net/index.html",
  sink = ltn12.sink.table(t)
}

print(table.concat(t))

for k, v in pairs(hdr) do
	print(tostring(k), '->', tostring(v))
end]]