require "imports.DataTypes.Objects"

local boss = require("imports.boss")
boss.Position = {x=290, y=500}
local PillarColor = {150,150,150,255}

for i,v in pairs(PillarColor) do
	PillarColor[i] = v/255
end

obj = {
	StageInfo = {
		AirFriction = 0.3,
		Spawn = {x=0, y=150}
	},
	Platforms = {
		Platform(-500, 800, 1000, 20),-- Floor
		Platform(-500, 0, 1000, 20),-- Ceiling
		Platform(-515, 0, 5, 820, {1,0,0,1}),-- Left Wall Background
		Platform(510, 0, 5, 820, {1,0,0,1}),-- Right Wall Background
		Platform(-525, 0, 10, 820),-- Left Wall 1
		Platform(-510, 0, 10, 820),-- Left Wall 2
		Platform(500, 0, 10, 820),-- Right Wall 1
		Platform(515, 0, 10, 820),-- Right Wall 2
		Platform(-480, 820, 10, 300, PillarColor),-- Start of pillars
		Platform(-430, 820, 10, 300, PillarColor),--
		Platform(-380, 820, 10, 300, PillarColor),--
		Platform(-330, 820, 10, 300, PillarColor),--
		Platform(-280, 820, 10, 300, PillarColor),--
		Platform(-230, 820, 10, 300, PillarColor),--
		Platform(-180, 820, 10, 300, PillarColor),--
		Platform(-130, 820, 10, 300, PillarColor),--
		Platform(-80, 820, 10, 300, PillarColor),--
		Platform(-30, 820, 10, 300, PillarColor),--
		Platform(20, 820, 10, 300, PillarColor),--
		Platform(70, 820, 10, 300, PillarColor),--
		Platform(120, 820, 10, 300, PillarColor),--
		Platform(170, 820, 10, 300, PillarColor),--
		Platform(220, 820, 10, 300, PillarColor),--
		Platform(270, 820, 10, 300, PillarColor),--
		Platform(320, 820, 10, 300, PillarColor),--
		Platform(370, 820, 10, 300, PillarColor),--
		Platform(420, 820, 10, 300, PillarColor),--
		Platform(470, 820, 10, 300, PillarColor),-- End of pillars
	},
	Others = {
	},
	Actors = {
		boss
	}
}

return obj