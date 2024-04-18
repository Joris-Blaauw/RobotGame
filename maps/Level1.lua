require "imports.DataTypes.Objects"
obj = {
	StageInfo = {
		AirFriction = 0.3,
		Spawn = {x=0, y=650}
	},
	Platforms = {
		Platform(-2000, -130, 5000, 30), -- Ceiling
		Platform(-2000, 800, 2480, 20), -- Floor
		Platform(-2000, -130, 20, 930), -- Left Wall
		Platform(-2000, 700, 50, 2), -- Platform to get to secret on the left
		DeathPlane(480, 805, 420, 10), -- First Death Plane
		Platform(580, 700, 220, 3), -- Platform Above Death Plane
		Platform(900, 800, 320, 20), -- Platform After Death Plane
		Platform(1200, 600, 20, 200), -- Wall going up to next platfom
		Platform(1200, 600, 500, 20), -- Platform with first enemy
		Platform(1680, 400, 20, 220), -- Second wall going up
		Platform(1680, 400, 320, 20), -- Second raised platform with coins goinf off
		Platform(1980, 400, 20, 2500), -- Wall closing off fist section
		Platform(2300, 500, 200, 5), -- Small pillar platform 1
		Platform(2390, 500, 20, 2500), -- Pillar holding up platform 1
		Platform(2350, 500, 100, 20), -- Transition from platform to pillar 1
		Platform(2800, 500, 200, 5), -- Small pillar platform 2
		Platform(2890, 500, 20, 2500), -- Pillar holding up platform 2
		Platform(2850, 500, 100, 20), -- Transition from platform to pillar 2
		Platform(3200, 600, 1200, 20), -- Landing platform after pillars
		Platform(4400, 400, 20, 220), -- Wall going up to victory platform
		Platform(4400, 400, 250, 20), -- Victory Platform		
		MapWarp(4550, 250, 20, 150, "boss"), -- Map Warp
		Platform(4550, 250, 30, 20, {0.96, 0.76, 0.26, 1}), -- Victory Door Top
		Platform(4565, 250, 15, 150, {0.96, 0.76, 0.26, 1}), -- Victory Door Back
	},
	Others = {
		Sign(600, 750, "!!!DANGER!!!", 20),
		Sign(1300, 400, "Jump On Him", 20),
		Sign(4400, 250, "Victory!", 30)
	},
	Actors = {
		-- Enemies
		Enemy(1500, 500, "Walker"),
		Enemy(1900, 300, "Jumper"),
		Enemy(4200, 520, "FireballThrower"),

		-- Coins
		Coin(-1970, 400), -- Coin on the left
		Coin(634, 550),Coin(674, 500),Coin(714, 550), -- Coin triangle above death pit
		Coin(2000, 200),Coin(2100, 150),Coin(2200, 150), -- Coins that lead the player to the first pillar platform
		Coin(2544, 300),Coin(2634, 250),Coin(2724, 300) -- Coin arch between pillars
	}
}

return obj