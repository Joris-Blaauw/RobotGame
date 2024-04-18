local texture = love.graphics.newImage("Textures/Boss/Walk.png")

local boss = {
	Type = "Enemy",
	EnemyType = "Boss",
	Texture = texture,
	Position = {x=0, y=0},
	Velocity = {x=0, y=0},
	MovementSpeed = 0.6,
	StunTimer = 2,
	JumpChargeTimer = 0,
	CurrentAnimation = "walk",
	AnimationTimer = 0.0,
	AnimationFrame = 1,
	AnimationIterations = 0,
	Direction = "Left",
	w = 84,
	h = 84,
	Animations = {
		walk = {
			FrameWidth = 84,
			FrameAmount = 4,
			FrameTime = 0.1,
			Texture = "Textures/Boss/Walk.png"
		},
		stun = {
			FrameWidth = 84,
			FrameAmount = 2,
			FrameTime = 1.2,
			Texture = "Textures/Boss/Stun.png"
		}
	}
}

boss.Animation = love.graphics.newQuad(0,0,boss.w,boss.h,texture)

return boss