require 'lfs'
require 'stringLib'

local t = {}

local function getFileName(path, noExtension)
	assert(path, 'no path')

	path = path:gsub('/', '\\')

	path = path:match('\\([^\\]*)$') or path

	if noExtension then
		path = path:match('([^%..]*)')
	end

	return path
end

io.getFileName = getFileName

local function getFolder(path)
	assert(path, 'no path')

	path = path:gsub('/', '\\')

	path = path:match('(.*\\)')

	return path
end

t.getFolder = getFolder

local function getFileExtension(path)
	assert(path, 'no path')

	local ext = getFileName(path):sub(getFileName(path, true):len() + 2, path:len())

	if (ext == '') then
		return nil
	end

	return ext
end

t.getFileExtension = getFileExtension

--[[function getWorkingDir()
	return io.popen('cd'):read('*l')
end

function getScriptDir()
	return getFolder(debug.getinfo(1).source:sub(1))
end]]

local function isAbsPath(path)
	assert(path, 'no path')

	if path:find(':') then
		return true
	end

	return false
end

t.isAbsPath = isAbsPath

local function getCallStack()
	local t = {}

	local c = 2

	while debug.getinfo(c, 'S') do
		local what = debug.getinfo(c, 'S').what

		if ((what == 'Lua') or (what == 'main')) then
			t[#t + 1] = debug.getinfo(c, 'S')
		end

		c = c + 1
	end

	return t
end

local function toFolderPath(path, shortened)
	assert(path, 'no path')

	path = path:gsub('/', '\\')

	if shortened then
		path = path:match('(.*)\\$') or path
	else
		if not path:match('\\$') then
			path = path..'\\'
		end
	end

	return path
end

t.toFolderPath = toFolderPath

local function toAbsPath(path, basePath)
	assert(path, 'no path')

	path = path:gsub('/', '\\')

	if isAbsPath(path) then
		return path
	end

	--local scriptDir = getFolder(scriptPath:gsub('/[^/]+$', ''))

	if (basePath == nil) then
		basePath = io.curDir()
	end

	local result = toFolderPath(basePath)

	while (path:find('..\\') == 1) do
		result = result:reduceFolder()

		path = path:sub(4)
	end

	result = result..path

	return result
end

t.toAbsPath = toAbsPath

local function curDir()
	return toFolderPath(lfs.currentdir())
end

t.curDir = curDir

local function local_path(level)
	if (level == nil) then
		level = 0
	end

	local path = getCallStack()[2 + level].source

	path = path:match('^@(.*)$')

	while ((path:find('.', 1, true) == 1) or (path:find('\\', 1, true) == 1)) do
		path = path:sub(2)
	end

	path = path:gsub('/', '\\')

	--path = path:match('(.*\\)') or ''

	if not io.isAbsPath(path) then
		path = io.curDir()..path
	end

	return path
end

t.local_path = local_path

local function local_dir(level)
	if (level == nil) then
		level = 0
	end

	local path = getCallStack()[2 + level].source

	path = path:match('^@(.*)$')

	while ((path:find('.', 1, true) == 1) or (path:find('\\', 1, true) == 1)) do
		path = path:sub(2)
	end

	path = path:gsub('/', '\\')

	path = path:match('(.*\\)') or ''

	if not io.isAbsPath(path) then
		path = io.curDir()..path
	end

	return path
end

t.local_dir = local_dir

local function pathExists(path)
	assert(path, 'no path')

	path = path:match('(.*[^\\])')

	return (lfs.attributes(toAbsPath(path, io.local_dir(1))) ~= nil)
end

t.pathExists = pathExists

 local function pathIsFile(path)
	return (lfs.attributes(toAbsPath(path, io.local_dir(1)), 'mode') == 'file')
end

t.pathIsFile = pathIsFile

 local function pathIsOpenable(path)
	assert(path, 'no path')

	local f = io.open(path, 'r')

	local result = (f ~= nil)

	if result then
		f:close()
	end

	return result
end

t.pathIsOpenable = pathIsOpenable

local function pathIsWritable(path)
	assert(path, 'no path')

	local f = io.open(path, 'w+')

	local result = (f ~= nil)

	if result then
		f:close()
	end

	return result
end

t.pathIsWritable = pathIsWritable

local function pathIsLocked(path)
	if not io.pathExists(path) then
		return true
	end

	local f = io.open(path, 'a')

	if (f ~= nil) then
		f:close()

		return false
	end

	return true
end

t.pathIsLocked = pathIsLocked

 local function local_require(path1)
	local path = toAbsPath(path1, io.local_dir(1))

	if package.loaded[path] then
		return
	end

	local packagePath = package.path

	package.path = getFolder(path)..'?.lua'
--print('require', path1, path, getFolder(path))
	local result = require(getFileName(path, true))

	package.path = packagePath

	return result
end

t.local_require = local_require

local function local_open(path, options)
--print('local_open', path, toAbsPath(path, io.local_dir(1)))
	return io.open(toAbsPath(path, io.local_dir(1)), options)
end

t.local_open = local_open

local function local_loadfile(path)
	return loadfile(toAbsPath(path, io.local_dir(1)))
end

t.local_loadfile = local_loadfile

local function isFolderPath(path)
	if (path == '') then
		return false
	end
	if (getFolder(path) == '') then
		return false
	end

	if (getFolder(path) ~= path) then
		return false
	end

	return true
end

t.isFolderPath = isFolderPath

string.reduceFolder = function(s, amount)
	assert(s, 'no path')

	if (amount == nil) then
		amount = 1
	end

	if (amount == 0) then
		return s
	end

	local dir = getFolder(s:sub(1, getFolder(s):len() - 1))
	local fileName = getFileName(s)

	if (dir == nil) then
		return fileName
	end

	return string.reduceFolder(dir..fileName, amount - 1)
end

local function getFiles(dir, filePath)
	assert(dir, 'no dir')

	dir = toFolderPath(dir)
	filePath = filePath or '*'

	local c = 0
	local t = {}

	local cmd = [[dir 2>NUL ]]..(dir..filePath):quote()..[[ /b /s]]

	for line in io.popen(cmd):lines() do
		if io.pathIsFile(line) then
			c = c + 1
			t[c] = line
		end
	end

	return t
end

t.getFiles = getFiles

local function getScriptDir(level)
	if (level == nil) then
		level = 1
	end

	return getFolder(debug.getinfo(level).source:sub(1))
end

t.getScriptDir = getScriptDir

local function changeWorkingDir(path)
	assert(path, 'no path specified')

	os.execute([[cd /d ]]..path:quote())
end

t.changeWorkingDir = changeWorkingDir

local function moveFile(sourcePath, targetPath)
	os.execute(string.format([[move 1>NUL 2>NUL %q %q]], sourcePath, targetPath))
end

t.moveFile = moveFile

local function renameFile(sourcePath, targetPath)
	os.execute(string.format([[rename 1>NUL 2>NUL %q %q]], sourcePath, targetPath))
end

t.renameFile = renameFile

local function createDir(path)
	assert(path, 'no path')

	path = toAbsPath(path, io.local_dir(1))

	assert(isFolderPath(path), 'createDir: path is no directory '..tostring(path))

	local function nest(path)
		local p = toFolderPath(path, true)

		if ((path == nil) or (path == '') or lfs.mkdir(p)) then
			return
		end

		nest(path:reduceFolder())

		local result, errorMsg = lfs.mkdir(p)

		--print('result', result, errorMsg)
	end

	nest(path)
end

t.createDir = createDir

local function createFile(path, overwrite)
	path = toAbsPath(path, io.local_dir(1))

	if not overwrite and io.pathExists(path) then
		print('createFile: path exists', path)

		return false
	end

	createDir(getFolder(path))

	local f = io.open(path, 'w+b')

	assert(f, 'cannot open '..tostring(path))

	f:close()

	return true
end

t.createFile = createFile

local function copyFile3(source, target)
	local sourceFile = io.open(source, 'rb')
	local targetFile = io.open(target, 'w+b')

	if (targetFile == nil) then
		os.execute([[mkdir ]]..getFolder(target):quote())

		targetFile = io.open(target, 'w+b')
	end

	targetFile:write(sourceFile:read('*a'))

	sourceFile:close()
	targetFile:close()
end

t.copyFile3 = copyFile3

local function copyDir3(source, target)
	os.execute([[xcopy ]]..source:quote()..[[ ]]..target:quote()..[[ /e /i /y /q]])
end

t.copyDir3 = copyDir3

local function copyFile(source, target, overwrite)
	assert(source, 'no source path')
	assert(target, 'no target path')

	source = toAbsPath(source, io.local_dir(1))
	target = toAbsPath(target, io.local_dir(1))

	createDir(getFolder(target))

	if isFolderPath(target) then
		target = target..getFileName(source)
	end

	if (not overwrite and io.pathExists(target)) then
		print('copyFile: target path exists', target)

		return
	end

	local sourceFile = io.open(source, 'rb')
	local targetFile = io.open(target, 'w+b')

	assert(sourceFile, 'copyFile: cannot open source '..tostring(source))
	assert(targetFile, 'copyFile: cannot open target '..tostring(target))

	local bufSize = 10000
	local fileSize = io.getFileSize(source)

	while (fileSize > 0) do
		targetFile:write(sourceFile:read(math.min(bufSize, fileSize)))

		fileSize = fileSize - bufSize
	end

	sourceFile:close()
	targetFile:close()

	return true
end

t.copyFile = copyFile

local function copyFileIfNewer(source, target)
	assert(source, 'no source path')
	assert(target, 'no target path')

	source = toAbsPath(source, io.local_dir(1))
	target = toAbsPath(target, io.local_dir(1))

	local targetMod = lfs.attributes(target, 'modification')

	if (targetMod ~= nil) then
		local sourceMod = lfs.attributes(source, 'modification')

		if ((sourceMod ~= nil) and (targetMod >= sourceMod)) then
			return
		end
	end

	copyFile(source, target, true)
end

t.copyFileIfNewer = copyFileIfNewer

local function copyFile2(source, target)
	createDir(getFolder(target))

	local sourceFile = io.open(source, 'rb')
	local targetFile = io.open(target, 'w+b')

	assert(sourceFile, 'copyFile: cannot open sourcePath', sourcePath)
	assert(targetFile, 'copyFile: cannot open targetPath', targetPath)

	targetFile:write(sourceFile:read('*a'))

	sourceFile:close()
	targetFile:close()
end

t.copyFile2 = copyFile2

local function copyDir2(source, target)
	--os.execute([[xcopy ]]..source:quote()..[[ ]]..target:quote()..[[ /e /i /y /q]])
	source = io.toAbsPath(source, io.local_dir(1))
	target = io.toAbsPath(target, io.local_dir(1))

	assert(source, 'copyDir: no source', source)
	assert(target, 'copyDir: no target', target)

	local sourceFolder = getFolder(source)
	local targetFolder = getFolder(target)

	createDir(targetFolder)

	local iter = lfs.dir(source)

	assert(iter, 'copyDir: source is no directory', source)

	for path in iter do
		if ((path ~= '.') and (path ~= '..')) then
			copyFile(sourceFolder..path, targetFolder..path)
		end
	end
end

t.copyDir2 = copyDir2

local function copyDir(source, target, overwrite)
	--os.execute([[xcopy ]]..source:quote()..[[ ]]..target:quote()..[[ /e /i /y /q]])

	source = toFolderPath(source)
	target = toFolderPath(target)

	source = io.toAbsPath(source, io.local_dir(1))
	target = io.toAbsPath(target, io.local_dir(1))

	assert(source, 'copyDir: no source', source)
	assert(target, 'copyDir: no target', target)

	local sourceFolder = getFolder(source)
	local targetFolder = getFolder(target)

	local iter = lfs.dir(source)

	local t = {}

	for path in iter do
		t[#t + 1] = path
	end

	createDir(targetFolder)

	assert(iter, 'copyDir: source is no directory', source)

	for _, path in pairs(t) do
		if ((path ~= '.') and (path ~= '..')) then
			local sourcePath = sourceFolder..path
			local targetPath = targetFolder..path

			if io.pathIsFile(sourcePath) then
				copyFile(sourcePath, targetPath, overwrite)
			else
				sourcePath = toFolderPath(sourcePath)
				targetPath = toFolderPath(targetPath)

				copyDir(sourcePath, targetPath, overwrite)
			end
		end
	end
end

t.copyDir = copyDir

local function getFilesEx(path)
	path = toAbsPath(path, io.local_dir(1))

	local iter = lfs.dir(path)

	local t = {}

	for targetPath in iter do
		if ((targetPath ~= '.') and (targetPath ~= '..')) then
			targetPath = path..targetPath

			if (lfs.attributes(targetPath, 'mode') == 'directory') then
				targetPath = targetPath..'\\'
			end

			t[#t + 1] = targetPath
		end
	end

	return t
end

t.getFilesEx = getFilesEx

local function removeFile(path)
	path = toAbsPath(path, io.local_dir(1))

	os.remove(path)
end

t.removeFile = removeFile

local function removeDir(path)
	path = toAbsPath(path, io.local_dir(1))

	assert(isFolderPath(path), 'removeDir: path is no directory '..tostring(path))

	local function nest(path)
		if ((path == nil) or (path == '')) then
			return
		end

		for _, targetPath in pairs(getFilesEx(path)) do
			nest(targetPath)
		end

		removeFile(path)
		lfs.rmdir(path)
	end

	nest(path)
end

t.removeDir = removeDir

local function flushDir(path)
	assert(path, 'no path')

	path = toAbsPath(path, io.local_dir(1))

	assert(isFolderPath(path), 'recreateDir: path is no directory '..tostring(path))

	removeDir(path)

	createDir(path)
end

t.flushDir = flushDir

local function chdir(path)
	assert(path, 'no path')

	lfs.chdir(path)
end

t.chdir = chdir

local function getGlobal(name)
	local f = io.local_open(name, 'r')

	if not f then
		return nil
	end

	local valType = f:read()
	local val = f:read()

	f:close()

	if (val == nil) then
		return valType
	end

	val = stringToType(val, valType)

	return val
end

t.getGlobal = getGlobal

local function setGlobal(name, val)
	if (val == nil) then
		removeFile(name)

		return
	end

	local valType = type(val)

	assert((valType ~= 'table'), 'cannot save table')

	local f = io.local_open(name, 'w+')

	f:write(valType, '\n', tostring(val))

	f:close()
end

t.setGlobal = setGlobal

local function getFileSize(path)
	assert(path, 'no path')

	assert(io.pathExists(path), 'path '..tostring(path)..' does not exist')

	assert(io.pathIsOpenable(path), 'cannot open '..tostring(path))

	return lfs.attributes(path, 'size')
end

t.getFileSize = getFileSize

local function syntaxCheck(path)
	assert(path, 'no path')

	local f, errorMsg = loadfile(path)

	return (errorMsg == nil), errorMsg
	--[[local ring = rings.new()

	ring:dostring('package.path = '..valToLua(getFolder(path)..'?.lua'))

	local res, msg, trace = ring:dostring('require '..valToLua(getFileName(path, true)))

	return res, msg, trace]]
end

t.syntaxCheck = syntaxCheck

local function loadfileSyntaxCheck(path, throwError)
	assert(path, 'no path')

	local res, errorMsg = syntaxCheck(path)

	if not res then
		if throwError then
			error(errorMsg)
		end

		return nil, errorMsg
	end

	local f = loadfile(path)

	if (f == nil) then
		local errorMsg = 'could not open '..tostring(path)

		if throwError then
			error(errorMsg)
		end

		return nil, errorMsg
	end

	return f
end

t.loadfileSyntaxCheck = loadfileSyntaxCheck

local function printTrace(s)
	print(debug.traceback(tostring(s), 2))
	io.flush(io.stdout)
end

t.printTrace = printTrace

for k, v in pairs(t) do
	io[k] = v
end