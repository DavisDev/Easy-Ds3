--[[ 
	Tai Config Library.
	Search, Insert, Delete your plugins fast!.
	
	Licensed by Creative Commons Attribution-ShareAlike 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Designed By DevDavisNunez (https://twitter.com/DevDavisNunez),
	Date: 12/07/2017 at 06:40 pm
]]

tai = {}

--[[
	NIL tai.load()
	When executing this function, the txt is loaded completely to ram, 
	thus allowing the native parse, quickly and easily and work in a virtual way its contents.
]]
function tai.load(path)
	local path = path or "ux0:tai/config.txt"
	if not files.exists(path) then path = "ur0:tai/config.txt" end
	print("Loading taiCfg from %s\n",path)
	tai.raw = {}
	if files.exists(path) then
		for line in io.lines(path) do
			table.insert(tai.raw, line)
		end
		tai.parse()
	end
	tai.path = path
	tai.debug()
	tai.repair()
	tai.debug()
end

--[[
	NIL tai.parse()
	When executing this function, the txt is parsed to native arrays and can work by index direct.
]]
function tai.parse()
	if tai.raw then
		tai.gameid = {}
		local id_sect = nil
		for i=1, #tai.raw do
			local line = tai.raw[i]
			if line:find("*",1) then -- Secction Found.
				id_sect = line:sub(2);
				--print("Section found %s\n", id_sect)
				if not tai.gameid[id_sect] then tai.gameid[id_sect] = {line = {}, prx = {}} end
				table.insert(tai.gameid[id_sect].line, i)
				continue;
			end
			if id_sect and not line:find("#",1) then -- Is a path and not a comment.
				--print("[%s]: %s\n", id_sect, line:lower())
				table.insert(tai.gameid[id_sect].prx, {path=line:lower(), line=i})
			end
		end
	end
end

--[[
	NIL tai.repair()
	When executing this function, a massive scan is done in the txt, of scattered GAMEID�s,
	concentrating these into a single one, and preserving the first id found in the txt, or if section is void, delete.
	Useful to repair previous errors in the use of the same.
]]
function tai.repair()
	if tai.raw and tai.gameid then
		for k,v in pairs(tai.gameid) do
			local len = #v.line
			if len > 1 then
				tai.delete_sect(v) -- Remove al sections of id...
				
				-- Reinsert in first pos! :D
				table.insert(tai.raw,v.line[1], "*"..k)
				for a=1, #v.prx do
					table.insert(tai.raw,v.line[1]+a, v.prx[a].path)
				end
				
				tai.parse()
				return tai.repair() -- recursive! :D
			elseif #v.prx < 1 then -- No have any plug?, remove!!!!
				tai.delete_sect(v) -- Remove al sections of id...
				tai.parse()
				return tai.repair() -- recursive! :D
			end
		end
	end
end

function tai.delete_sect(v) -- Internal use...
	local len = #v.line
	for a=len, 1, -1 do
		for b=#v.prx, 1, -1 do
			if v.prx[b].line > v.line[a] and not v.prx[b].rv then
				--print("Line: %d - Removed: %s\n", v.prx[b].line,
				table.remove(tai.raw, v.prx[b].line)--)
				v.prx[b].rv = true
			end
		end
		--print("Line: %d - Removed: %s\n",v.line[a],
		table.remove(tai.raw, v.line[a])--)
	end
end

--[[
	NUMBER tai.find(id, path)
	Search a filename in the list of plugin of the id.
	return nil in case of error, index in success.
]]
function tai.find(id, path)
	if not tai.gameid[id] then return nil end
	local fname = files.nopath(path)
	fname = fname:lower()
	for i=1, #tai.gameid[id].prx do
		local x1,x2 = string.find(tai.gameid[id].prx[i].path:lower(), fname, 1, true)
		if x1 then
			return i;
		end
	end
	return nil;
end

--[[
	NUMBER tai.put(id, path)
	Add a filename in the list of plugin of the id, if the id no exists, then create a id or if exists id and path then nothing do!
	return false in case of error, true in success.
]]
function tai.put(id, path)
	local idx = tai.find(id, path)
	if idx then -- Nothing to do... :O ?
		--tai.gameid[id].prx[idx].path = 
	elseif tai.gameid[id] then -- Exists the id then have any prx!
		idx = #tai.gameid[id].prx
		table.insert(tai.raw, tai.gameid[id].prx[idx].line+1, path)
		tai.parse() -- Refresh all ids lines etc..
		--tai.debug()
		return true;
	else -- New ID new path!
		table.insert(tai.raw, "*"..id)
		table.insert(tai.raw, path)
		tai.parse() -- Refresh all ids lines etc..
		--tai.debug()
		return true;
	end
	return false;
end
--[[
	NUMBER tai.del(id, path)
	Remove a filename in the list of plugin of the id, if the id no have more prx, its erase!
	return false in case of error, true in success.
]]
function tai.del(id, path)
	local idx = tai.find(id, path)
	if idx then
		table.remove(tai.raw, tai.gameid[id].prx[idx].line)
		if #tai.gameid[id].prx == 1 then -- remove section if not have nothing more prx!
			table.remove(tai.raw, tai.gameid[id].line[1])
		end
		tai.parse() -- Refresh all ids lines etc..
		--tai.debug()
		return true;
	end
	return false;
end
--[[
	NIL tai.sync([path])
	Can send a path to sync or use the default.
	Synchronize all the changes made so far with the library.
]]
function tai.sync(path)
	if tai.raw then
		files.write(path or tai.path, table.concat(tai.raw, '\n'))
	end
end

function tai.debug()
	return nil
	--[[print("### CONFIG.TXT ##\n")
	if tai.raw then
		for i=1,#tai.raw do
			print("#%03d: %s\n",i,tai.raw[i])
		end
	end
	print("##################\n")]]
end

--[[ ## Simple test ##

tai.load(files.fullpath("config.txt",0))
print("Find: %s\n",tostring(tai.find("KERNEL", "ux0:cheDs4vita.skprx")))
print("Put: %s\n",tostring(tai.put("main", "ur0:tai/pngshot.suprx")))
print("Put: %s\n",tostring(tai.put("ONELUA4R0", "ur0:tai/functions.suprx")))
print("Del: %s\n",tostring(tai.del("CNPEZ0002", "ux0:algunamadre.suprx")))
print("Del: %s\n",tostring(tai.del("NPUG80318", "ux0:adrenaline/adrenaline.suprx")))
tai.sync()
buttons.waitforkey()
err()
]]