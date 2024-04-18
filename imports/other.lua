function MoveCamera(Object, x, y) -- Gets the position that an object should be at relative to the camera 
	WindowWidth, WindowHeight = love.graphics.getDimensions()
	MirageObject = {
		x = (Object.x-x)+((WindowWidth/2)-(player.Shape.w/2)),
		y = (Object.y-y)+((WindowHeight/2)-(player.Shape.h/2))
	}
	return MirageObject
end

string.startswith = function(self, str)
	return self:find('^'..str) ~= nil
end

function Average(Numbers) -- Returns the average of a list of numbers
	TotalAverage = 0
	NumberCount = 0
	for _,num in pairs(Numbers) do
		TotalAverage = TotalAverage + num
		NumberCount = NumberCount + 1
	end
	return TotalAverage / NumberCount
end

function log(Level, ...) -- Logs a value to the console output and a log file with a specified warning value
	Filepath = "Logs/"..StartDateFormatted..".txt"
	for _,Data in pairs({...}) do
		FormattedData = "["..Level.."] "..os.date("[%H.%M.%S]").." : "..make_readable(Data)
		if love.filesystem.getInfo(Filepath) then
			love.filesystem.append(Filepath, FormattedData.."\n")
		else
			love.filesystem.write(Filepath, FormattedData.."\n")
		end
		print(FormattedData)
	end
end

function CreateSaveDir()
	RequiredDirs = {
		"Logs",
		"CrashLogs"
	}
	for _,Dir in pairs(RequiredDirs) do
		if not love.filesystem.getInfo(Dir) then
			love.filesystem.createDirectory(Dir)
		end
	end
end

function CheckCollision(obj1, obj2)
	if obj1.x + obj1.w > obj2.x and obj1.x < obj2.x + obj2.w and obj1.y + obj1.h > obj2.y and obj1.y < obj2.y + obj2.h then
		return true
	end
	return false
end

function LoadMap(MapPath)
	StageData = nil
	objects = nil
	log("Info", "Loading New Map At: "..MapPath)
	EnemyData = require "imports.DataTypes.EnemyData"
	package.loaded[MapPath] = nil
	StageData = require(MapPath)
	LastPositionsX = {}
	LastPositionsY = {}
	player.Position = StageData.StageInfo.Spawn
	SpawnPosition = StageData.StageInfo.Spawn
	objects = {
		Platforms = {},
		Others = {},
		Actors = {}
	}
	for _,obj in pairs(StageData.Actors) do
		if obj.Type == "Enemy" then
			local SpecificEnemyData = EnemyData[obj.EnemyType]
			if not (obj.EnemyType == "Boss") then
				obj.Texture = SpecificEnemyData.Texture
			end
			obj.Stompable = SpecificEnemyData.Stompable
			obj.MovementSpeed = SpecificEnemyData.MovementSpeed
			obj.hp = SpecificEnemyData.hp
			obj.w = SpecificEnemyData.w
			obj.h = SpecificEnemyData.h
			obj.JumpForce = SpecificEnemyData.JumpForce
		end
		if obj.EnemyType == "Boss" then
			obj.Stompable = false
			obj.StunTimer = 2
			obj.Position = {x=290, y=500}
			obj.hp = 5
			obj.AnimationFrame = 0
			obj.FrameTimer = 0
		end
	end
	player.Position = StageData.StageInfo.Spawn
	player.Velocity = {x=0, y=0}
end

function ProcessConsoleCommand(Command)
	CMDArgs = {}
	for arg in Command:gmatch("%S+") do
		table.insert(CMDArgs, arg)
	end
	if Command == "fly" then
		if not isUsingFlyCheat then
			isUsingFlyCheat = true
			player.Velocity = {x=0, y=0}
		else
			isUsingFlyCheat = false
		end
	elseif Command == "kill" then
		player.Death(SpawnPosition)
	elseif CMDArgs[1] == "tp" then
		if CMDArgs[2] and CMDArgs[3] then
			local newcoords = {x=tonumber(CMDArgs[2]), y=tonumber(CMDArgs[3])}
			player.Position = newcoords
		else
			return false
		end
	elseif Command == "debug" then
		log("Info", "Debug mode toggled")
		if DEBUG then
			DEBUG = false
		else
			DEBUG = true
		end
	elseif Command == "god" then
		if player.State.GodMode then
			player.State.GodMode = false
		else
			player.State.GodMode = true
		end
	elseif CMDArgs[1] == "load" then
		if not CMDArgs[2] then return false end
		if file_exists("maps/"..CMDArgs[2]..".lua") then
			LoadMap("maps/"..CMDArgs[2])
		else
			return false
		end
	elseif CMDArgs[1] == "run" then
		for i,arg in pairs(CMDArgs) do
			if i > 1 then
				local chunk = loadstring(arg)
				if chunk then
					chunk()
				end
			end
		end
	elseif CMDArgs[1] == "force" then
		if _G[CMDArgs[2]] then
			if CMDArgs[3] then
				_G[CMDArgs[2]](CMDArgs[3])
			else
				_G[CMDArgs[2]]()
			end
		end
	elseif CMDArgs[1] == "mod" then
		if CMDArgs[2] == "load" then
			if CMDArgs[3] then
				if file_exists("mods/"..CMDArgs[3]..".lua") then
					table.insert(GameMods, {internal=require("mods/"..CMDArgs[3]), name=CMDArgs[3]})
					GameMods[#GameMods].internal.load()
				else
					return false
				end
			end
		elseif CMDArgs[2] == "unload" then
			if CMDArgs[3] then
				for i,mod in pairs(GameMods) do
					if mod.name:lower() == CMDArgs[3]:lower() then
						if mod.internal.unload then
							mod.internal.unload()
						end
						table.remove(GameMods, i)
					end
				end
			else
				GameMods = {}
			end
		end
	elseif CMDArgs[1] == "vel" then
		if CMDArgs[2] and CMDArgs[3] then
			local newvel = {x=tonumber(CMDArgs[2]), y=tonumber(CMDArgs[3])}
			player.Velocity = newvel
		else
			return false
		end
	elseif CMDArgs[1] == "setting" then
		if CMDArgs[2] and CMDArgs[3] then
			for _,v in pairs(player.Settings) do
			end
			if player.Settings[CMDArgs[2]] then
				player.Settings[CMDArgs[2]] = tonumber(CMDArgs[3])
			else
				return false
			end
		else
			return false
		end
	elseif CMDArgs[1] == "spy" then
		if CMDArgs[2] and CMDArgs[3] then
			if CMDArgs[2] == "add" then
				if _G[CMDArgs[3]] then
					if not table.contains(TrackedVars, CMDArgs[3]) then
						table.insert(TrackedVars, CMDArgs[3])
					end
				else
					return false
				end
			elseif CMDArgs[2] == "remove" then
				for i,v in pairs(TrackedVars) do
					if v == CMDArgs[3] then
						table.remove(TrackedVars, i)
						if RemoveValue then
							RemoveValue(v)
						end
						return true
					end
				end
				return false
			else
				return false
			end
		else
			return false
		end
	elseif CMDArgs[1] == "exit" or CMDArgs[1] == "quit" then
		log("Warn", "Terminating program, "..CMDArgs[1].." command")
		love.event.quit()
	else
		for _,mod in pairs(GameMods) do
			if mod.internal.cmd then
				if mod.internal.cmd(CMDArgs) then
					return true
				end
			end
		end
		return false
	end
	return true
end

function table.contains(table, content)
	for _,value in pairs(table) do
		if value == content then
			return true
		end
	end
	return false
end

function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

function make_readable(value, TabAmount)
	if not TabAmount then
		TabAmount = 0
	end
	local FinalString = ""

	ValueType = type(value)
	if ValueType == "string" then
		FinalString = "\""..value.."\""
	elseif ValueType == "number" or ValueType == "function" or ValueType == "boolean" then
		FinalString = tostring(value)
	elseif ValueType == "table" then
		FinalString =  "{\n"
		local Iter = 0
		local TableLen = GetTableLen(value)
		for key, Val in pairs(value) do
			FinalString = FinalString..string.rep("	", TabAmount+1)..key.." = "..make_readable(Val, TabAmount+1)..""
			Iter = Iter + 1
			if Iter < TableLen then
				FinalString = FinalString..","
			end
			FinalString = FinalString.."\n"
		end
	FinalString = FinalString..string.rep("	", TabAmount).."}"
	else
		FinalString = ValueType
	end
	return FinalString
end

function convertFromRGB(value)
	for i,v in pairs(value) do
		value[i] = v/255
	end
	return value
end

function GetTableLen(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function PlaySound(Sound)
	love.audio.play(Sound)
end