# Info

---
I made this game in LOVE2d (lua) for a school assignment. It was supposed to be a simple boss fight, 
but i got sidetracked and i made it a bit more complicated than probably necessary.

# Controls:

---

- [W] - Fly up
- [A] - Move left
- [S] - Fly down
- [D] - Move right
- [SPACE] - Jump


# CONSOLE STUFF

---
### How to open:
[w,w,s,s,a,d,a,d,b,a] (konami code)

---
### Controls:
- [/] - Open / Close console
- [RETURN] - Send console command


# Console Commands:

---
- "fly" - Toggles fly cheat

- "kill" - kills the player

- "tp x y" - tps the player to the specified coordinates (e.g. "tp 2500 300")

- "vel x y" - sets the player's velocity

- "debug" - toggle debug mode (hitboxes, show invisible walls)

- "god" - toggles god mode

- "load Filename" - Loads a custom map file in the maps folder (e.g. "load Testmap" will load the map data from the "Testmap.lua" file in the maps directory)

- "run code" - Runs any lua code given afterwards, where each arguement is a new line (e.g. "run print('Hello!'" will print Hello, and "run player.Death()" will kill the player)

- "force command args" - Run a command in the code with the specified arg (e.g. "force player.Death" will kill the player and "force LoadMap maps\Testmap" will load the test map)

- "mod [load/unload] <modname>" - Loads a lua file from the mods directory. there are 2 mods that i included myself. (Template, with some info on how mods work. and InfoMenu, an infomenu that displays info, allows other mods to display info in that menu as well. also used internally sometimes, but only if it's enabled.) mods have access to load, update, draw and cmd functions. (the first 3 are the same as the love. variants, the cmd is called when a console command is ran.)
PS: mods are also loaded from the "modlist.lua" file, which passes a table with strings. the strings are mod names that you would input in the command

- "setting" - Changes a setting to a specified value.
List of settings: CameraSmoothingRecursion, PlatformRenderdistanceLeniency, ActorRenderdistanceLeniency

- "spy [add/remove] varname" - Adds or removes a variable from the tracking list. (needs InfoMenu mod)

- "quit / exit" - force closes the program


# Now, some more info about the game's code:

---
main.lua runs all the calculations and setup
Fonts contains some fonts
imports contains importable files. e.g. functions / data structures
maps contains all the map data. (you can put custom maps here too! just copy an existing one, modify some stuff and load it through a console command! "load <filename>" (filename is exlcuding ".lua"))
mods contains all mods. (again, you can make custom ones too! copy Template.lua and work it out from there. load it through the in-game console command or by adding the filename excluding ".lua" to the modlist.lua table)
Textures contain all the game's textures
Sounds contain all the sounds used in the game

imports/player.lua contains the data structure of the player
imports/other.lua has some miscelaneous functions
imports/boss.lua contains the data structure for the boss
imports/DataTypes contains some other data structures for various other things

imports/DataTypes/EnemyData.lua contains ROM data for all the enemy types
imports/DataTypes/Objects.lua contains the data structure for all the objects used in map data


# Extras:

---
The game's map loading function / mod functions may not work when compiled due to the check to see if the file exists fails.
Also, you need LOVE2D installed to run it.
