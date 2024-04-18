require "imports.DataTypes.Objects"
obj = {
	StageInfo = {
		AirFriction = 0.3,
		Spawn = {x=0,y=0}
	},
	Platforms = {
		Invisible(-20, -200, 20, 720),
		Platform(0, 500, 700, 20), -- Starter platform
		Platform(700, 300, 20, 220), -- Vertical wall and next platform
		Platform(700, 300, 200, 20),

		Platform(890, 300, 10, 150), -- The death plane pit
		DeathPlane(900, 440, 190, 10),
		Platform(1090, 300, 10, 150),
		Platform(1100, 300, 1000, 20),
		Platform(1200, 280, 20, 20),
		Platform(2000, 280, 20, 20),
	},
	Others = {
		Sign(-200, 500, "Invisible Wall!", 15),
		Sign(100, 300, "Welcome to the test level!", 20),
		Sign(920, 200, "The first death pit ever!", 15),
		Sign(1400, 200, "Enemy Test Zone", 15)
	},
	Actors = {
		Enemy(1500, 236, "FasterWalker"),
		Enemy(1600, 250, "Fireball")
	}
}

return obj