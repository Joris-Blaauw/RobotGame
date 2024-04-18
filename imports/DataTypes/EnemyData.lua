obj = {
	Walker = {
		MovementSpeed = 3,
		hp = 1,
		w = 64,
		h = 64,
		JumpForce = 0,
		Texture = love.graphics.newImage("Textures/enemy.png"),
		Stompable = true
	},
	Jumper = {
		MovementSpeed = 0,
		hp = 1,
		w = 64,
		h = 64,
		JumpForce = 15,
		Texture = love.graphics.newImage("Textures/enemy.png"),
		Stompable = true,
	},
	FasterWalker = {
		MovementSpeed = 5,
		hp = 2,
		w = 64,
		h = 64,
		JumpForce = 0,
		Texture = love.graphics.newImage("Textures/enemy.png"),
		Stompable = true
	},
	Boss = {
		MovementSpeed = 5,
		hp = 5,
		w = 84,
		h = 84,
		JumpForce = 15,
		Stompable = true,
	},
	Fireball = {
		MovementSpeed = 5,
		hp = 1,
		w = 24,
		h = 24,
		JumpForce = 8,
		Texture = love.graphics.newImage("Textures/fireball.png"),
		Stompable = false,
	},
	FireballThrower = {
		MovementSpeed = 0,
		hp = 1,
		w = 64,
		h = 64,
		JumpForce = 0,
		Texture = love.graphics.newImage("Textures/enemy.png"),
		Stompable = true,
	},
	Dummy = {
		MovementSpeed = 0,
		hp = 1,
		w = 64,
		h = 64,
		JumpForce = 0,
		Texture = love.graphics.newImage("Textures/enemy.png"),
		Stompable = true
	}
}

return obj