require "imports.other"

love.load = function() -- load map data and othe values
	CreateSaveDir()
	StartTime = os.time()
	StartDateFormatted = os.date("%d-%m-%y_%H.%M.%S")
	log("Info", "Loading Game...")
	BossExitTimer = 0
	hasBeatenBoss = false
	holdingPauseButton = false
	PAUSED=false
	isUsingFlyCheat = false
	ConsoleTyping = false
	CONSOLE = false
	KCODE = ""
	modlist = require "mods/modlist"
	GameMods = {}
	if not (modlist == {}) then
		for i,modName in pairs(modlist) do
			local mod = require("mods/"..modName)
			if mod.load then
				mod.load()
				local modData = {
				name = modName,
				internal = mod
				}
				table.insert(GameMods, modData)
				log("Info", "Found and loaded mod "..modName)
			end
		end
	else
		log("Info", "No mods found in modlist")
	end
	ConsoleInput = ""
	TrackedVars = {}
	DEBUG=false
	player = require "imports.player"
	StageData = require "maps.Level1"
	EnemyData = require "imports.DataTypes.EnemyData"
	SpawnPosition = StageData.StageInfo.Spawn
	player.Position = {x=SpawnPosition.x, y=SpawnPosition.y}
	LastPositionsX = {}
	LastPositionsY = {}
	objects = {
		Platforms = {},
		Others = {},
		Actors = {}
	}
	-- Enemy data gets loaded in
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
	end
	love.window.setVSync(player.Settings.VSync)
	log("Info", "Game Loaded! Debug mode is ".. (DEBUG and "Enabled" or "Disabled"))
end

love.update = function(dt)
	if PAUSED or hasBeatenBoss then
		if love.keyboard.isDown("escape") then
			if not holdingPauseButton then
				PAUSED = not PAUSED
				holdingPauseButton = true
			end
		else
			holdingPauseButton = false
		end
		if hasBeatenBoss then
			if BossExitTimer > 0 then
				BossExitTimer = BossExitTimer - 1
			else
				log("Success", "Player has beaten the game!")
				love.event.quit()
			end
		end
		return
	end
	AdditionalX = 0
	isMoving = true
	-- Check for movement input and modify the player's Velocity accordingly
	if love.keyboard.isDown("d") then
		AdditionalX = AdditionalX + 60 * player.Physics.MovementSpeed * dt
	end
	if love.keyboard.isDown("a") then
		AdditionalX = AdditionalX - 60 * player.Physics.MovementSpeed * dt
	end

	if AdditionalX == 0 then -- This variable will be true if the player is trying to move in any direction
		isMoving = false
	end

	if not player.State.Grounded then
		AdditionalX = AdditionalX * (StageData.StageInfo.AirFriction * 2)
	end

	-- Create "Ghost Player" to calculate collisions without actually moving the player character
	GhostPlayer = {
		x = player.Position.x + (player.Velocity.x + AdditionalX),
		y = player.Position.y,
		w = player.Shape.w,
		h = player.Shape.h
	}
	
	-- Check for collisions based on the previously made / moved Ghost Player
	isXColliding = false
	for _,Platform in pairs(objects.Platforms) do
		isXColliding = CheckCollision(GhostPlayer, Platform)
		if isXColliding then
			if player.Velocity.x + AdditionalX > 0 then
				PlayerWallOffset = Platform.x - (player.Position.x + player.Shape.w)
			elseif player.Velocity.x + AdditionalX < 0 then
				PlayerWallOffset = (Platform.x + Platform.w) - player.Position.x
			else
				PlayerWallOffset = 0
			end
			if Platform.Type == "DeathPlane" then
				player.Death(StageData.StageInfo.Spawn)
			elseif Platform.Type == "MapWarp" then
				LoadMap(Platform.Map)
			end
			break
		end
	end

	-- If there are no collisions, execute the movement stuff on the "real" player
	if not isXColliding then
		player.Velocity.x = player.Velocity.x + AdditionalX
		if player.Velocity.x > player.Physics.TerminalX then
			player.Velocity.x = player.Physics.TerminalX
		elseif player.Velocity.x < (player.Physics.TerminalX * -1) then
			player.Velocity.x = player.Physics.TerminalX * -1
		end
	else
		player.Position.x = player.Position.x + PlayerWallOffset
		player.Velocity.x = 0
	end

	-- Modify the ghost player vertically
	GhostPlayer.y = player.Position.y + (player.Velocity.y + player.Physics.Gravity)
	GhostPlayer.x = player.Position.x

	-- Check the modified ghost player for vertical collisions
	isYColliding = false
	for _,Platform in pairs(objects.Platforms) do
		isYColliding = CheckCollision(GhostPlayer, Platform)
		if isYColliding then
			PlayerPlatformOffset = Platform.y - (player.Position.y + player.Shape.h)
			if player.Velocity.y >= 0 then
				player.State.Grounded = true
				player.State.JumpAmount = player.Stats.MaxJumps
				if not isMoving then
					if player.Velocity.x > 0 then
						if player.Velocity.x > Platform.friction then
							player.Velocity.x = player.Velocity.x - Platform.friction
						else
							player.Velocity.x = 0
						end
					elseif player.Velocity.x < Platform.friction then
						if player.Velocity.x < (Platform.friction * -1) then
							player.Velocity.x = player.Velocity.x + Platform.friction
						else
							player.Velocity.x = 0
						end
					end
				end
			end
			if Platform.Type == "DeathPlane" then
				player.Death(StageData.StageInfo.Spawn)
			elseif Platform.Type == "MapWarp" then
				LoadMap(Platform.Map)
			end
			break
		end
	end
	-- If there's no collisions, move the player downwards according to gravity
	if isYColliding then
		if player.Velocity.y > 0 then
			player.Position.y = player.Position.y + PlayerPlatformOffset
		end
		player.Velocity.y = 0
	else
		player.State.Grounded = false
		player.State.JumpAmount = 0
		if not isUsingFlyCheat then
			player.Velocity.y = player.Velocity.y + player.Physics.Gravity
		end
		if AdditionalX == 0 then
			if player.Velocity.x > 0 then
				if player.Velocity.x > StageData.StageInfo.AirFriction then
					player.Velocity.x = player.Velocity.x - StageData.StageInfo.AirFriction
				else
					player.Velocity.x = 0
				end
			elseif player.Velocity.x < StageData.StageInfo.AirFriction then
				if player.Velocity.x < (StageData.StageInfo.AirFriction * -1) then
					player.Velocity.x = player.Velocity.x + StageData.StageInfo.AirFriction
				else
					player.Velocity.x = 0
				end
			end
		end
	end

	-- Check enemy collision
	EnemyCollision = false
	local coinsToRemove = {}
	for _,obj in pairs(objects.Actors) do 
		FormattedObj = {
			x=obj.Position.x,
			y=obj.Position.y,
			w=obj.w,
			h=obj.h
		}
		EnemyCollision = CheckCollision(GhostPlayer, FormattedObj)
		if EnemyCollision then
			if obj.Type == "Enemy" then
				if obj.Stompable then
					if player.Velocity.y > 0 then
						player.Velocity.y = player.Physics.JumpForce * -0.8
						player.InvincibleTimer = 0.25
						for index,enemy in pairs(StageData.Actors) do
							if enemy.Type == "Enemy" then
								if enemy.ID == obj.ID then
									if obj.hp > 1 then
										StageData.Actors[index].hp = obj.hp - 1
										if obj.EnemyType == "Boss" then
											obj.StunTimer = 2
											obj.Stompable = false
											obj.Velocity.y = 0
										end
									else
										if obj.EnemyType == "Boss" then
											PlaySound(player.Sounds.victory)
											hasBeatenBoss = true
											BossExitTimer = 200
										end
										table.remove(StageData.Actors, index)
									end
								end
							end
						end
						player.State.CurrentAnimation = "jump"
						player.State.AnimationTimer = player.Animations[player.State.CurrentAnimation].Frametime
						player.State.AnimationFrame = 0
						player.State.AnimationIterations = 0
						player.Texture = love.graphics.newImage(player.Animations[player.State.CurrentAnimation].Texture)
					else
						player.Death()
					end
				else
					player.Death()
				end
			elseif obj.Type == "Coin" then
				player.Coins = player.Coins + 1
				for i,actor in pairs(StageData.Actors) do
					if actor.Type == "Coin" then
						if actor.ID == obj.ID then
							table.insert(coinsToRemove, i)
						end
					end
				end
			end
		end
	end

	for _,i in ipairs(coinsToRemove) do
    	table.remove(StageData.Actors, i)
	end

	if love.keyboard.isDown("space") then
		if player.State.JumpAmount > 0 then
			PlaySound(player.Sounds.jump)
			player.Velocity.y = -1 * player.Physics.JumpForce
			player.State.JumpAmount = player.State.JumpAmount - 1
			player.State.Grounded = false
			player.State.CurrentAnimation = "jump"
			player.State.AnimationTimer = player.Animations[player.State.CurrentAnimation].Frametime
			player.State.AnimationFrame = 0
			player.State.AnimationIterations = 0
			player.Texture = love.graphics.newImage(player.Animations[player.State.CurrentAnimation].Texture)
		end
	end

	if isUsingFlyCheat then
		local flyVelocity = 0
		if love.keyboard.isDown("w") then
			flyVelocity = -10
		end
		if love.keyboard.isDown("s") then
			flyVelocity = flyVelocity + 10
		end
		player.Position.y = player.Position.y + flyVelocity
	end

	-- Move player accoding to movement imports/DataTypes/vector.lua contains data structure for a vector (x=0, y=0), but it's barely used.

	player.MoveByVector(player.Velocity)

	-- Handle Animation Selection
	if AdditionalX > 0 then
		player.State.Facing = "Right"
	elseif AdditionalX < 0 then
		player.State.Facing = "Left"
	end

	local changed = false
	if player.State.Grounded then
		if math.abs(player.Velocity.x) > 0.5 then
			if math.abs(player.Velocity.x) > 8 then
				if not (player.State.CurrentAnimation == "run") then
					player.State.CurrentAnimation = "run"
					changed = true
				end
			else
				if not (player.State.CurrentAnimation == "walk") then
					player.State.CurrentAnimation = "walk"
					changed = true
				end
			end
		else
			if not (player.State.CurrentAnimation == "idle") then
				player.State.CurrentAnimation = "idle"
				changed = true
			end
		end
	else
		if not (player.State.CurrentAnimation == "jump") or player.State.AnimationIterations > 1 then
			if not (player.State.CurrentAnimation == "fall") then
				player.State.CurrentAnimation = "fall"
				changed = true
			end
		end
	end

	if changed then
		player.State.AnimationTimer = player.Animations[player.State.CurrentAnimation].Frametime
		player.State.AnimationFrame = 0
		player.State.AnimationIterations = 0
		player.Texture = love.graphics.newImage(player.Animations[player.State.CurrentAnimation].Texture)
	end

	if love.keyboard.isDown("escape") then
		if not holdingPauseButton then
			PAUSED = not PAUSED
			holdingPauseButton = true
		end
	else
		holdingPauseButton = false
	end

	if player.Position.y > 1500 then
		player.Death(StageData.StageInfo.Spawn)
	end

	player.State.AnimationTimer = player.State.AnimationTimer + dt
	if player.StunTimer > 0 then
		player.StunTimer = player.StunTimer - dt
		if player.StunTimer < 0 then
			player.StunTimer = 0
		end
	end

	if player.InvincibleTimer > 0 then
		player.InvincibleTimer = player.InvincibleTimer - dt
		if player.InvincibleTimer < 0 then
			player.InvincibleTimer = 0
		end
	end

	-- Actor Movement Handler
	for _,Actor in pairs(objects.Actors) do
		if Actor.Type == "Enemy" then
			if Actor.EnemyType == "Boss" then
				Actor.AnimationTimer = Actor.AnimationTimer + dt
				if Actor.StunTimer > 0 then
					Actor.StunTimer = Actor.StunTimer - dt
					if Actor.StunTimer < 0 then
						Actor.Stompable = true
						Actor.StunTimer = 0
					else
						Actor.Stompable = false
					end
				end
				if Actor.JumpChargeTimer > 0 then
					Actor.JumpChargeTimer = Actor.JumpChargeTimer - dt
					if Actor.JumpChargeTimer < 0 then
						Actor.JumpChargeTimer = 0
					end
				end
			end
			if Actor.EnemyType == "FireballThrower" then
				if Actor.StunTimer > 0 then
					Actor.StunTimer = Actor.StunTimer - dt
					if Actor.StunTimer < 0 then
						Actor.StunTimer = 0
					end
				else
					local FireballObject = {
						ID = EnemyID,
						Type = "Enemy",
						Position = {x=Actor.Position.x, y=Actor.Position.y},
						Velocity = {x=0, y=0},
						EnemyType = "Fireball",
						Direction = Actor.Direction,
						StunTimer = 0
					}
					for k,v in pairs(EnemyData["Fireball"]) do
						FireballObject[k] = v
					end
					EnemyID = EnemyID + 1
					Actor.StunTimer = 1.5
					table.insert(StageData.Actors, FireballObject)
				end
			end
			if Actor.Direction == "Left" then
				Direction = -1
			else
				Direction = 1
			end
			GhostEnemy = {
				x = Actor.Position.x + (Actor.MovementSpeed * Direction),
				y = Actor.Position.y,
				w=Actor.w,
				h=Actor.h
			}
			isXEnemyColliding = false
			for _,Platform in pairs(objects.Platforms) do
				isXEnemyColliding = CheckCollision(GhostEnemy, Platform)
				if isXEnemyColliding then
					if Actor.EnemyType == "Fireball" then
						for i,act in pairs(StageData.Actors) do
							if act.Type == "Enemy" then
								if act.ID == Actor.ID then
									table.remove(StageData.Actors, i)
									break
								end
							end
						end
						break
					end
					if Actor.Direction == "Left" then
						Actor.Direction = "Right"
					elseif Actor.Direction == "Right" then
						Actor.Direction = "Left"
					end
					if Actor.Direction == "Left" then
						EnemyXPlatformOffset = Platform.x - (GhostEnemy.x + Actor.w)
					elseif Actor.Direction == "Right" then
						EnemyXPlatformOffset = (Platform.x + Platform.w) - GhostEnemy.x
					end
					break
				end
			end
			if Actor.Direction == "Left" then
				Direction = -1
			else
				Direction = 1
			end
			if Actor.StunTimer then
				if Actor.StunTimer <= 0 then
					Actor.Position.x = Actor.Position.x + (Actor.MovementSpeed * Direction)
					if Actor.EnemyType == "Boss" then
						if not (Actor.CurrentAnimation == "walk") then
							Actor.CurrentAnimation = "walk"
							Actor.AnimationTimer = Actor.Animations[Actor.CurrentAnimation].FrameTime
							Actor.AnimationFrame = 0
							Actor.AnimationIterations = 0
							Actor.Texture = love.graphics.newImage(Actor.Animations[Actor.CurrentAnimation].Texture)
						end
					end				
				else
					if Actor.EnemyType == "Boss" then
						if not (Actor.CurrentAnimation == "stun") then
							Actor.CurrentAnimation = "stun"
							Actor.AnimationTimer = Actor.Animations[Actor.CurrentAnimation].FrameTime
							Actor.AnimationFrame = 0
							Actor.AnimationIterations = 0
							Actor.Texture = love.graphics.newImage(Actor.Animations[Actor.CurrentAnimation].Texture)
						end
					end
				end
			else
				if not isXEnemyColliding then
					Actor.Position.x = Actor.Position.x + (Actor.MovementSpeed * Direction)
				else
					Actor.Position.x = Actor.Position.x + EnemyXPlatformOffset
				end
			end
			GhostEnemy.y = GhostEnemy.y + (Actor.Velocity.y + (player.Physics.Gravity))
			GhostEnemy.x = Actor.Position.x
			isYEnemyColliding = false
			for _,Platform in pairs(objects.Platforms) do
				isYEnemyColliding = CheckCollision(GhostEnemy, Platform)
				if isYEnemyColliding then
					if not YCOlCounter then
						YCOlCounter = 1
					else
						YCOlCounter = YCOlCounter + 1
					end
					EnemyPlatformOffset = Platform.y - (Actor.Position.y + Actor.h)
					break
				end
			end
			if isYEnemyColliding then
				if Actor.Velocity.y > 0 then
					Actor.Position.y = Actor.Position.y + EnemyPlatformOffset
				end
				Actor.Velocity.y = 0
				if Actor.EnemyType == "Jumper" or Actor.EnemyType == "Fireball" then
					Actor.Velocity.y = Actor.JumpForce * -1
				elseif Actor.EnemyType == "Boss" then
					if Actor.StunTimer <= 0 then
						RandVal = love.math.random() * 50
						if RandVal < 1 then
							Actor.Velocity.y = Actor.JumpForce * -1
						end
					end
				end
			else
				Actor.Velocity.y = Actor.Velocity.y + player.Physics.Gravity
				Actor.Position.y = Actor.Position.y + Actor.Velocity.y
			end
		end
	end
	if ConsoleTyping then
		if love.keyboard.isDown("return") then
			if not (ConsoleInput == "") then
				log("Console", "~ "..ConsoleInput)
				local TempCmd = ConsoleInput
				ConsoleInput = ""
				CmdSuccess = ProcessConsoleCommand(TempCmd)
				if CmdSuccess then
					ConsoleTyping = false
				elseif InfoElements then
					ChangeValue("Command Failed", TempCmd)
				end
			end
			ConsoleInput = ""
		end
		if love.keyboard.isDown("backspace") then
			if not isDeleting then
				isDeleting = true
				ConsoleInput = ConsoleInput:sub(1, -2)
			end
		else
			isDeleting = false
		end
	end
	if not (TrackedVars == {}) then
		for _,var in pairs(TrackedVars) do
			if _G[var] then
				if ChangeValue then
					ChangeValue(var, make_readable(_G[var]))
				else
					log("SPY", _G[var])
				end
			end
		end
	end
	if not (GameMods == {}) then
		for _,mod in pairs(GameMods) do
			if mod.internal.update then
				mod.internal.update(dt)
			end
		end
	end
end

love.draw = function()
	local BackgroundImage = love.graphics.newImage("Textures/Background.png")
	love.graphics.draw(BackgroundImage, 0, 0)

	-- Draw the player at its position
	WindowWidth, WindowHeight = love.graphics.getDimensions()
	table.insert(LastPositionsX, 1, player.Position.x)
	table.remove(LastPositionsX, (player.Settings.CameraSmoothingRecursion + 1))
	table.insert(LastPositionsY, 1, player.Position.y)
	table.remove(LastPositionsY, (player.Settings.CameraSmoothingRecursion + 1))

	AvgX = Average(LastPositionsX)
	AvgY = Average(LastPositionsY)

	-- Filter objects based on if they're inside the screen
	objects = {
		Platforms = {},
		Others = StageData.Others,
		Actors = {}
	}
	hasBoss = false
	for _,obj in pairs(StageData.Actors) do
		if obj.EnemyType == "Boss" then
			hasBoss = true
			objects.Actors = StageData.Actors
			objects.Platforms = StageData.Platforms
			break
		end
	end

	if not hasBoss then
		LeftSide = (AvgX + player.Shape.w/2) - (WindowWidth/2)
		RightSide = LeftSide + WindowWidth
		UpSide = (AvgY + player.Shape.h/2) - (WindowHeight/2)
		DownSide = UpSide + WindowHeight
		for _,obj in pairs(StageData.Platforms) do
			inScreenChecks = 0
			if obj.x < RightSide+player.Settings.PlatformRenderdistanceLeniency then
				inScreenChecks = inScreenChecks + 1
			end
			if obj.x + obj.w > LeftSide-player.Settings.PlatformRenderdistanceLeniency then
				inScreenChecks = inScreenChecks + 1
			end
			if obj.y < DownSide+player.Settings.PlatformRenderdistanceLeniency then
				inScreenChecks = inScreenChecks + 1
			end
			if obj.y + obj.h > UpSide-player.Settings.PlatformRenderdistanceLeniency then
				inScreenChecks = inScreenChecks + 1
			end
			isInScreen = inScreenChecks > 3
			if isInScreen then
				table.insert(objects.Platforms, obj)
			end
		end

		for _,obj in pairs(StageData.Actors) do
			inScreenChecks = 0
			if obj.Position.x < RightSide+player.Settings.ActorRenderdistanceLeniency then
				inScreenChecks = inScreenChecks + 1
			end
			if obj.Position.x + obj.w > LeftSide-player.Settings.ActorRenderdistanceLeniency then
				inScreenChecks = inScreenChecks + 1
			end
			if obj.Position.y < DownSide+player.Settings.ActorRenderdistanceLeniency then
				inScreenChecks = inScreenChecks + 1
			end
			if obj.Position.y + obj.h > UpSide-player.Settings.ActorRenderdistanceLeniency then
				inScreenChecks = inScreenChecks + 1
			end
			isInScreen = inScreenChecks > 3
			if isInScreen then
				table.insert(objects.Actors, obj)
			end
		end
	end
	-- Draw all platforms in the map data

	-- Draw all platforms as rectangles
	for _,obj in pairs(objects.Platforms) do
		MirageObj = MoveCamera(obj, AvgX, AvgY)
		if obj.Type == "Platform" or obj.Type == "DeathPlane" or DEBUG then
			love.graphics.setColor(obj.Color)
			love.graphics.rectangle("fill", MirageObj.x, MirageObj.y, obj.w, obj.h)
			love.graphics.setColor(1, 1, 1)
		end
	end

	-- Draw all other objects as their respective render type
	for _,obj in pairs(objects.Others) do
		MirageObj = MoveCamera(obj, AvgX, AvgY)
		if obj.Type == "Sign" then
			love.graphics.print(obj.Text,obj.Font, MirageObj.x, MirageObj.y)
		end
	end

	-- Draw all actors (enemies, powerups, etc...)
	for _,obj in pairs(objects.Actors) do
		MirageObj = MoveCamera(obj.Position, AvgX, AvgY)
		if DEBUG then
			love.graphics.setColor(1, 0, 0, 1)
			love.graphics.rectangle("line", MirageObj.x, MirageObj.y, obj.w, obj.h)
			love.graphics.setColor(1, 1, 1, 1)
		end
		if not obj.Texture then
			obj.Texture = love.graphics.newImage("Textures/placeholder.png")
		end
		if obj.EnemyType == "Boss" then
			if obj.AnimationTimer > obj.Animations[obj.CurrentAnimation].FrameTime then
				obj.AnimationTimer = obj.AnimationTimer - obj.Animations[obj.CurrentAnimation].FrameTime
				obj.AnimationFrame = obj.AnimationFrame + 1
				if obj.AnimationFrame > obj.Animations[obj.CurrentAnimation].FrameAmount then
					obj.AnimationFrame = 1
					obj.AnimationIterations = obj.AnimationIterations + 1
				end
				obj.Animation = love.graphics.newQuad(obj.Animations[obj.CurrentAnimation].FrameWidth * (obj.AnimationFrame - 1), 0, obj.w, obj.h, obj.Texture)
			end
			love.graphics.draw(obj.Texture, obj.Animation, MirageObj.x, MirageObj.y)
		else
			if obj.Direction == "Left" then
				love.graphics.draw(obj.Texture, MirageObj.x, MirageObj.y)
			else
				love.graphics.draw(obj.Texture, MirageObj.x + obj.w, MirageObj.y, 0, -1, 1)
			end
		end
	end

	-- Draw collision boxes if debug mode is active
	if DEBUG then
		love.graphics.setColor(1, 0, 0, 1)
		love.graphics.rectangle("line", (WindowWidth/2)-(player.Shape.w / 2) - (AvgX - player.Position.x), (WindowHeight/2)-(player.Shape.h / 2) - (AvgY - player.Position.y), player.Shape.w, player.Shape.h)
		love.graphics.setColor(1, 1, 1, 1)
	end
	RenderX = (WindowWidth/2)-(player.Shape.aw / 2) - (AvgX - player.Position.x)
	RenderY = (WindowHeight/2)-(player.Shape.ah / 2) - (AvgY - player.Position.y)

	-- Handle Animation Graphic Assignment
	if player.State.AnimationTimer > player.Animations[player.State.CurrentAnimation].Frametime then
		player.State.AnimationTimer = player.State.AnimationTimer - player.Animations[player.State.CurrentAnimation].Frametime
		player.State.AnimationFrame = player.State.AnimationFrame + 1
		if player.State.AnimationFrame > player.Animations[player.State.CurrentAnimation].FrameAmount then
			player.State.AnimationFrame = 1
			player.State.AnimationIterations = player.State.AnimationIterations + 1
		end

		player.Animation = love.graphics.newQuad(player.Animations[player.State.CurrentAnimation].FrameWidth * (player.State.AnimationFrame - 1), 0, player.Shape.aw, player.Shape.ah, player.Texture)
	end

	if player.State.Facing == "Right" then

		love.graphics.draw(player.Texture, player.Animation, RenderX, RenderY)
	else
		love.graphics.draw(player.Texture, player.Animation, (RenderX + player.Shape.aw), RenderY, 0, -1, 1)
	end

	-- Daw HUD
	if ConsoleTyping then
		love.graphics.setColor(0.1, 0.1, 0.1, 1)
		love.graphics.rectangle("fill", 5, 5, WindowWidth - 10, 20)
		love.graphics.setColor(1,1,1,1)
		love.graphics.print("~ "..ConsoleInput, 10, 10)
	end
	if not (GameMods == {}) then
		for _,mod in pairs(GameMods) do
			if mod.internal.draw then
				mod.internal.draw()
			end
		end
	end
	if PAUSED then
		love.graphics.setColor(0, 0, 0, 0.8)
		love.graphics.rectangle("fill", 0, 0, WindowWidth, WindowHeight)
		love.graphics.setColor(1, 1, 1, 1)
		local font = love.graphics.newFont("Fonts/Ftw.ttf", 40)
		love.graphics.print("PAUSED", font, 320, 250)
	end
	if hasBeatenBoss then
		love.graphics.setColor(0, 1, 0, 0.8)
		love.graphics.rectangle("fill", 0, 0, WindowWidth, WindowHeight)
		love.graphics.setColor(1, 1, 1, 1)
		local font = love.graphics.newFont("Fonts/Ftw.ttf", 50)
		love.graphics.print("You Win!",font,320,250)
	end
end

-- Console
function love.textinput(t)
	if CONSOLE then
		if t == "/" then
			if ConsoleTyping then
				ConsoleTyping = false
			else
				ConsoleTyping = true
			end
		elseif ConsoleTyping then
		    ConsoleInput = ConsoleInput..t
		end
	else
		if table.contains({"w","a","s","d","b","a"}, string.lower(t)) then
			KCODE = KCODE..string.lower(t)
			if string.find(KCODE, "wwssadadba") then
				log("Info", "Konami Code Entered! Console on!")
				CONSOLE = true
				KCODE = ""
				ConsoleTyping = true
			end
		else
			KCODE = ""
		end
	end
end

--TODO:

--In Progress:

--DONE:
-- Find enemy / boss textures
-- Improve stage (maybe)
-- Make boss
-- Think of a way to damage the boss / enemies
-- Make boss stage
-- Make enemy system
-- Make a test stage
-- Make animation engine
-- Make Coin System
-- Make console (i was bored)
-- Make mod support