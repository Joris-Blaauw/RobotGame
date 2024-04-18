function load() -- Load gets called when the mod is loaded. either through the modlist or through the mod command. this function is REQUIRED for the game to find the mod
	log("Info", "Mod Loaded")
	GameTimer = 0
	FrameCounter = 0
end

function update(dt) -- update is called when the game updates (notably it's called AFTER all the internal updates)
	GameTimer = GameTimer + dt
end

function draw() -- draw is called when the frame is being drawn. (notably it's called AFTER all the internal draws, which means that it will draw on top of the game by default)
	FrameCounter = FrameCounter + 1
	love.graphics.print(tostring(GameTimer), 5, 5)
	love.graphics.print(tostring(FrameCounter), 5, 25)
end

function cmd(CommandArgs) -- cmd is called when someone uses a console command. the return is nesesary so the game knows it's recieved in one of the mods. (CommandArgs is a table with all the passed args)
	if CommandArgs[1] == "ping" then
		print("pong")
	else
		return false
	end
	return true
end

return {load=load,update=update,draw=draw,cmd=cmd}