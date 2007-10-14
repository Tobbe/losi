-- -----------------------------------------------------------------------------
-- rcparser.lua
-- Makes it easy to edit .rc files with lua
--
-- Use the read(f) function to read a .rc file
-- Use the values table to change the values in the rc file you just read
-- Use write() to write the changes back to file
--
-- Usage:
-- --myprogram.lua
-- require 'rcparser'
--
-- rcparser.read('C:\\LiteStep\\Themes\\InstDef\\theme.rc')
-- rcparser.values['ThemeAuthor'] = 'Tobbe'
-- rcparser.values['ThemeVersion'] = '1.0'
-- rcparser.write()
-- -----------------------------------------------------------------------------

local io_lines = io.lines
local io_open = io.open
local tconcat = table.concat
local tostring = tostring
local pairs = pairs
local sub = string.gsub
local print = print
local error = error

module(...)

-- -----------------------------------------------------------------------------
-- values will become a map where the keys are the settingsnames from the parsed
-- file. The values are the settingsvalues read from the same file.
-- -----------------------------------------------------------------------------
values = {}

local function parse(s)
	local rest, key, comment = {}
	local e, group = #s + 1
	local i = s:find '[^ \t]' or e
	while i < e do
		local c, d = s:sub(i, i)
		if key and c == '"' or "'" == c then
			group = true
			d = s:find(c, i + 1, 0) or e
			d = d + 1
		elseif c == ';' then
			comment = s:sub(i)
			break
		else
			group = false
			d = s:find('[ \t]', i) or e
		end
		local tok = s:sub(i, d - 1)
		if not group then
			local z = s:find(';', i, 0)
			if z and z < d then
				tok = s:sub(i, z - 1)
				comment = s:sub(z)
				d = e
			end
		end
		if not key then
			key = tok
		else
			rest[ #rest + 1 ] = tok
		end
		i = s:find('[^ \t]', d + 1) or e
	end
	return key, rest, comment
end

local seen = {}

local lines = {}
local filename

-- -----------------------------------------------------------------------------
-- Reads a file
-- @param f
--      the filename of the file to read
-- -----------------------------------------------------------------------------
function read(f)
	filename = f
	local key, rest, comment

	for k, v in pairs(values) do
		seen[k] = false
	end

	for line in io_lines(f) do
		key, rest, comment = parse(line)
		--if key and values[key:lower()] then
		if key then
			seen[key:lower()] = true
			lines[#lines + 1] = {key, tconcat(rest, ' '), comment or ''}
			rest[1] = (rest[1] or '"'):gsub('"','')
			values[key:lower()] = rest
		else
			lines[#lines + 1] = {line}
		end
	end

	for k, v in pairs(seen) do
		if not v then
			lines[#lines + 1] = {k, values[k], ''}
		end
	end

	--[[for k, v in pairs(values) do
		print("key", k)
		for k, v in pairs(v) do
			print("value", k, v)
		end
	end]]--
end

local function update()
	for i = 1, #lines do
		if #lines[i] > 1 then
			local key = lines[i][1]:lower()
			if values[key] then
				lines[i][2] = tostring(values[key])
			end
		end
	end
end

local function trim(s)
	return (sub(s, "^%s*(.-)%s*$", "%1"))
end

-- -----------------------------------------------------------------------------
-- Writes all the data back out to file
-- -----------------------------------------------------------------------------
function write()
	update()

	local t = {}

	for i = 1, #lines do
		t[i] = trim(tconcat(lines[i], ' '))
	end

	local fh, err = io_open(filename, 'w')

	if not fh then
		error(err)
	end

	fh:write(tconcat(t, '\n'))
	fh:close()
end
