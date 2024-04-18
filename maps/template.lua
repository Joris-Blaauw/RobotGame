require "imports.DataTypes.Objects" -- Import object types used by the game. look in imports/DataTypes/Objects for all the objects
obj = {
	StageInfo = { -- Contains info about the stage
		AirFriction = 0.3, -- Friction applied when in the air
		Spawn = {x=0, y=0} -- Spawning position of the player
	},
	Platforms = { -- Contains all the platforms in the map
		Platform(-100, 300, 800, 20, {0, 0, 0, 1}), -- Platform object with arguments: [<xpos> <ypos> <width> <height> <table of color values (rgba)>]
		Invisible(-150, -500, 50, 800), -- Invisible platform with arguments: [<xpos> <ypos> <width> <height>]
		DeathPlane(690, 150, 10, 150), -- Death Plane with arguments: [<xpos> <ypos> <width> <height>]
		MapWarp(690, 0, 10, 150, "Level1") -- Map warp with arguments: [<xpos> <ypos> <width> <height> <mapname>]
	},
	Others = {
		Sign(0, 100, "Template Map", 50) -- Text Display with arguments: [<xpos> <ypos> <text> <fontsize>]
	},
	Actors = {
		Coin(640, 150), -- Coin object with arguments: [<xpos> <ypos>]. Coin IDs get handled internally
		Enemy(400, 200, "Dummy"), -- Enemy with arguments: [<xpos> <ypos> <EnemyType>] (check imports/DataTypes/EnemyData for all enemy types.)
	}
}

return obj