local texture = love.graphics.newImage("Textures/Player/idle.png")


local player = {
	Texture = texture,
	Position = {x=0, y=0},
	Velocity = {x=0, y=0},
	Coins = 0,
	StunTimer = 0,
	InvincibleTimer = 0,
	Physics = {
		MovementSpeed = 0.6,
		Gravity = 0.6,
		TerminalX = 10,
		TerminalY = 50,
		JumpForce = 15.5
	},
	State = {
		GodMode = false,
		HasGravity = true,
		Grounded = false,
		JumpAmount = 0,
		CurrentAnimation = "idle",
		AnimationTimer = 0.0,
		AnimationFrame = 1,
		Facing = "Left",
		AnimationIterations = 0,
	},	
	Shape = {
		w = 50,
		h = 128,
		aw = 128,
		ah = 128
	},
	Stats = {
		MaxJumps = 1
	},
	Settings = {
		CameraSmoothingRecursion = 8, -- Determines how many player positions the camera should average out to achieve the smoothing effect
		PlatformRenderdistanceLeniency = 250, -- Value in pixels of how "forgiving" the rendering of platforms should be (render platforms that far out outside the camera)
		ActorRenderdistanceLeniency = 100, -- Same as the one above, but for actors (moving stuff). if this is lower than the platform one, all enemies will clip through all the floors so dont pls
		VSync = 1, -- Enables or disables VSync
	},
	Animations = {
		idle = {
			FrameWidth = 128,
			FrameAmount = 1,
			Frametime = 1,
			Texture = "Textures/Player/idle.png"
		},
		walk = {
			FrameWidth = 128,
			FrameAmount = 12,
			Frametime = 0.05,
			Texture = "Textures/Player/walk.png"
		},
		run = {
			FrameWidth = 128,
			FrameAmount = 8,
			Frametime = 0.08,
			Texture = "Textures/Player/run.png"
		},
		fall = {
			FrameWidth = 128,
			FrameAmount = 1,
			Frametime = 0.2,
			Texture = "Textures/Player/fall.png"
		},
		jump = {
			FrameWidth = 128,
			FrameAmount = 1,
			Frametime = 0.15,
			Texture = "Textures/Player/jump.png"
		}
	},
	Sounds = {
		jump = love.audio.newSource("Sounds/Player/jump.wav", "static"),
		victory = love.audio.newSource("Sounds/Player/victory.wav", "static")
	}
}

player.Animation = love.graphics.newQuad(0,0,player.Shape.aw,player.Shape.ah,texture)

function player.MoveByVector(Vector)
	player.Position.x = player.Position.x + Vector.x
	player.Position.y = player.Position.y + Vector.y
end

function player.Death(SpawnPos)
	if not player.State.GodMode then
		if not (player.InvincibleTimer > 0) then
			LoadMap("maps/level1")
			if not SpawnPos then
				SpawnPos = SpawnPosition
			end
			player.Position = {x=SpawnPos.x, y=SpawnPos.y}
			player.Velocity = {x=0, y=0}
			LastPositionsX = {}
			LastPositionsY = {}
		end
	end
end

return player