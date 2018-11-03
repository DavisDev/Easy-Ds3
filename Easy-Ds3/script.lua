--[[ 
	Easy Ds3
	
	Licensed by GNU General Public License v3.0
	
	Designed By:
	- DevDavisNunez (https://twitter.com/DevDavisNunez).
	
	Version 0.01 at 14:00 pm - 14/09/17
	Version 0.1 at 21:00 pm - 04/08/18
	
]]

color.loadpalette()
dofile("git/updater.lua")
local splash = image.load("splash.png")
splash:blit(0,0)
screen.flip()
dofile("lib/wave.lua")


local wave = newWave()
wave:begin("wave.png")
local back = image.load("sce_sys/livearea/contents/bg0.png")

-- Loading language file
__LANG = os.language():lower()

dofile("lang/english_us.txt")
if files.exists("lang/"..__LANG..".txt") then dofile("lang/"..__LANG..".txt") end

--[[
	## Library Scroll ##
	Designed By DevDavis (Davis Nuñez) 2011 - 2017.
	Based on library of Robert Galarga.
	Create a obj scroll, this is very usefull for list show
	]]
function newScroll(a,b,c)
	local obj = {ini=1,sel=1,lim=1,maxim=1,minim = 1}
	function obj:set(tab,mxn,modemintomin) -- Set a obj scroll
		obj.ini,obj.sel,obj.lim,obj.maxim,obj.minim = 1,1,1,1,1
		--os.message(tostring(type(tab)))
		if(type(tab)=="number")then
			if tab > mxn then obj.lim=mxn else obj.lim=tab end
			obj.maxim = tab
		else
			if #tab > mxn then obj.lim=mxn else obj.lim=#tab end
			obj.maxim = #tab
		end
		if modemintomin then obj.minim = obj.lim end
	end
	function obj:max(mx)
		obj.maxim = #mx
	end
	function obj:up()
		if obj.sel>obj.ini then obj.sel=obj.sel-1
		elseif obj.ini-1>=obj.minim then
			obj.ini,obj.sel,obj.lim=obj.ini-1,obj.sel-1,obj.lim-1
		end
	end
	function obj:down()
		if obj.sel<obj.lim then obj.sel=obj.sel+1
		elseif obj.lim+1<=obj.maxim then
			obj.ini,obj.sel,obj.lim=obj.ini+1,obj.sel+1,obj.lim+1
		end
	end
	function obj:test(x,y,h,tabla,high,low,size)
		local py = y
		for i=obj.ini,obj.lim do 
			if i==obj.sel then screen.print(x,py,tabla[i],size,high)
			else screen.print(x,py,tabla[i],size,low)
			end
			py += h
		end
	end
	if a and b then
		obj:set(a,b,c)
	end
	return obj
end

-- Ajust string width w/newline char...
function wordwrap(text,width,w) 
	if not w then w = 1.0 end
	lines = 1                                     
	out = ""                                       
	int = ""                                      
  	for word in string.gmatch(text,"%S+") do       
    		if screen.textwidth (int.." "..word,w) > width then
      			out = out..'\n'                            
     			int = ""                                   
     			lines = lines + 1                         
    		end
  		out = out.." "..word                           
  		int = int.." "..word                           
  	end
  	return out                            
end

function textwrap(text,width)
	local out = "" -- new string
	local input = text / "\n"
	for i=1,#input do
		out += wordwrap(input[i], width).."\n"
	end
	return out
end

function files.write(path,data,mode) -- Write a file.
	local fp = io.open(path, mode or "w+");
	if fp == nil then return end
	fp:write(data);
	fp:flush();
	fp:close();
end

function files.read(path,mode) -- Read a file.
	local fp = io.open(path, mode or "r")
	if not fp then return nil end
	local data = fp:read("*a")
	fp:close()
	return data
end


dofile("lib/tai.lua")
tai.load("ur0:/tai/config.txt") -- First load config.txt

local ds3_state = tai.find("KERNEL", "ur0:tai/ds3vita.skprx")

local last_check_sum = files.crc32("ds3vita.skprx")

function INSTALL()
	if ds3_state then
		os.message(DS3_STATUS_PREVIUS_ENABLE)
	else
		local check_sum = 0
		if files.exists("ur0:tai/ds3vita.skprx") then
			check_sum = files.crc32("ur0:tai/ds3vita.skprx")
		end
		if check_sum != last_check_sum then
			files.copy("ds3vita.skprx", "ur0:/tai/")
		end
		tai.put("KERNEL", "ur0:tai/ds3vita.skprx")
		tai.sync()
		--os.taicfgreload()
		os.message(DS3_STATUS_ENABLE)
		os.message(MSG_ALERT_RESTART)
		power.restart()
	end
	ds3_state = tai.find("KERNEL", "ur0:tai/ds3vita.skprx")
end

function UNINSTALL()
	if ds3_state then
		tai.del("KERNEL", "ur0:tai/ds3vita.skprx")
		tai.sync()
		os.message(DS3_STATUS_DISABLE)
		os.message(MSG_ALERT_RESTART)
		power.restart()
	else
		os.message(DS3_STATUS_PREVIUS_DISABLE)
	end
	ds3_state = tai.find("KERNEL", "ur0:tai/ds3vita.skprx")
end

-- 
local menu = {
	{t = MENU_ACTION_ENABLE, f =  INSTALL},
	{t = MENU_ACTION_DISABLE, f =  UNINSTALL},
	{t = MENU_ACTION_EXIT, f =  os.exit},
}
local scr = newScroll(menu, 3)
local net_mac = os.mac() or "00:00:00:00:00:00";
local m1,m2,m3,m4,m5,m6 = net_mac:match("(.+):(.+):(.+):(.+):(.+):(.+)")
local bt_mac = string.format("%02X:%02X:%02X:%02X:%02X:%02X", tonumber(m1,16),tonumber(m2,16),tonumber(m3,16),tonumber(m4,16),tonumber(m5,16),tonumber(m6,16)+1)

local instrucction = TEXT_INSTRUCCTION

instrucction = textwrap(instrucction, 720);

for i=255, 0, -2.5 do
	splash:blit(0,0, i)
	screen.flip()
end

while true do
	buttons.read()
	if back then back:blit(0,0) end
	wave:blit(4)
	draw.fillrect(0,0,960,25,color.shine)
	screen.print(480,5,("Easy Ds3 v%X.%02X"):format(APP_VERSION_MAJOR, APP_VERSION_MINOR), 1, color.white, 0x0, __ACENTER)
	local py = 35
	if ds3_state then
		screen.print(950, py, DS3_STATUS_ENABLE, 1, color.green, 0x0, __ARIGHT)
	else
		screen.print(950, py, DS3_STATUS_DISABLE, 1, color.red, 0x0, __ARIGHT)
	end
	for i=scr.ini,scr.lim do 
		if i==scr.sel then 
			screen.print(480, py, "-> "..menu[i].t, 1, color.cyan, 0x0, __ACENTER)
		else 
			screen.print(480, py, menu[i].t, 1, color.gray, 0x0, __ACENTER)
		end
		py += 25
	end
	screen.print(480, py+10, PSV_BT_ADDR..bt_mac, 1, color.green, 0x0, __ACENTER)
	
	py += 60
	--for l = 1, #instrucction do
		screen.print(480, py, instrucction, 1, color.white, 0x0, __ACENTER)
		--py += 25
	--end
	
	screen.flip()
	if buttons.cross then
		menu[scr.sel].f()
	end
	if buttons.up then scr:up()
	elseif buttons.down then scr:down()
	end
	--if buttons.select then
		--err()
	--end
end
