# Endless Void
Endless Void is a fully functional level builder for Void Stranger. 

You can create your own levels with it, and upload them to a server (a [Voyager](https://github.com/hexfae/voyager) instance).

This repository contains:
- Its GameMaker project file
- batch/shell/UndertaleModTool scripts necessary for development and merging (in `/projectscripts/`)
- Patches applied to the game on-merge (in `/patches`).

The project is set up like this, as opposed to just a plain UndertaleModTool mod, for several reasons:
- Faster iteration, as a lot of changes can be tested by just running the GameMaker project without merging
- When the game updates, it will be trivial to update with it
- Ability to use GameMaker's animation curves (in a non-painful way)
- Ability to use GameMaker's debugger for code in the project
- Ability to use things that the UndertaleModTool (de)compiler would usually not like (in a non-painful way)
- Ability to open-source the project

## Installing
To install this mod, you'll need an application that can do xdelta patching. I recommend [Delta Patcher.](https://www.romhacking.net/utilities/704/)

- Go to the [latest release](https://github.com/Skirlez/void-stranger-endless-void/releases/latest) and grab the .xdelta file which matches your copy of Void Stranger (Steam/itch.io).
- Apply the xdelta patch to Void Stranger's data.win file, which is found in its installation folder.  (On Steam, right-click the game, Manage->Browse local files) **Make sure it's the original, vanilla data.win. If you previously installed this mod, or any other mod, restore the original data.win first.** in order to uninstall the mod, bring back the original data.win in any way (either keep a backup, or on Steam, find and press the "verify integrity of the game files" button).


On Steam only, you can keep your original data.win by patching a copy of it, naming it "ev_data.win", and adding `-game "path\to\ev_data.win"` to the game's launch options.

Your save file will not be touched by the mod, and you can install and uninstall the mod without anything happening to it. Have fun!

## Building
See [Building Endless Void](https://github.com/Skirlez/void-stranger-endless-void/wiki/Building-Endless-Void-(Windows)) on the Wiki

## Things of note about the code
- Indices of objects, sprites, sounds, etc. become mismatched when merging with Void Stranger, so references to them are always obtained with `asset_get_index()`/`agi()`.
This does not apply to animation curves, as Void Stranger never uses them, and so their indices are not offset.
- Semicolons are lightly and inconsistently sprinkled throughout, because of muscle memory, but GameMaker does not enforce them...
- It's uh, pretty good, semi-occasionally.

## License
The code, with some exceptions, is licensed under the terms of the AGPLv3.
Exceptions being `gml_Object_obj_chest_small_Step_0.gml`, `gml_Object_obj_chest_small_Draw_0.gm`, `gml_Object_obj_floor_memory1_Create_0.gml`, `gml_Object_obj_floor_memory2_Create_0.gml`, `gml_Object_obj_floor_memory3_Create_0.gml`, `gml_Object_obj_player_Step_0.gml`, `gml_Object_obj_menu_Draw_0` and `gml_Object_obj_inventory_Create_0.gml`
all in the patches folder, since they are mostly copied decompiled code.

## Contributing
Please contribute
