CoinID = 0
EnemyID = 0
function Platform(x, y, width, height, color)
	if not color then
		color = {255, 255, 255}
	end
	obj = {
		Type = "Platform",
		Color = color,
		x = x,
		y = y,
		w = width,
		h = height,
		friction = 1 -- The higher the friction, the more the player will slow down when touching it
	}
	return obj
end

function Sign(x, y, Text, Scale)
	font = love.graphics.newFont("Fonts/Ftw.ttf", Scale)
	font:setFilter("nearest", "nearest")
	obj = {
		Type = "Sign",
		x = x,
		y = y,
		Text = tostring(Text),
		Font = font
	}
	return obj
end

function DeathPlane(x, y, width, height, color)
	if not color then
		color = {255, 0, 0}
	end
	obj = {
		Type = "DeathPlane",
		Color = color,
		x = x,
		y = y,
		w = width,
		h = height,
		friction = 1 -- The higher the friction, the more the player will slow down when touching it
	}
	return obj
end

function Invisible(x, y, width, height)
	obj = {
		Type = "Invisible",
		Color = {255, 0, 255},
		x = x,
		y = y,
		w = width,
		h = height,
		friction = 0
	}
	return obj
end

function Enemy(x, y, Type)
	obj = {
		ID = EnemyID,
		Type = "Enemy",
		Position = {x=x, y=y},
		Velocity = {x=0, y=0},
		EnemyType = Type,
		Direction = "Left",
		StunTimer = 0
	}
	EnemyID = EnemyID + 1
	return obj
end

function Powerup(x, y, Type)
	obj = {
		Type = "Powerup",
		Position = {x=x, y=y},
		w = w,
		h = h,
		PowerupType = Type,
		Direction = "Left"
	}
	return obj
end

function Coin(x, y)
	texture = love.graphics.newImage("Textures/coin.png")
	obj = {
		Type = "Coin",
		Position = {x=x, y=y},
		w = 32,
		h = 32,
		Texture = texture,
		ID = CoinID
	}
	CoinID = CoinID + 1
	return obj
end

function MapWarp(x, y, w, h, Map)
	if not Map then
		Map = "maps/Testmap"
	else
		Map = "maps/"..Map
	end
	obj = {
		Type = "MapWarp",
		x = x,
		y = y,
		w = w,
		h = h,
		Map = Map,
		Color = {0, 0, 255},
		friction = 1
	}
	return obj
end