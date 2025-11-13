# Endless Void
Endless Void is a fully functional level builder for Void Stranger. 

You can create your own levels with it, and upload them to a server (a [Voyager](https://github.com/hexfae/voyager) instance).

You can also build non-linear level packs.

This repository contains:
- Its GameMaker project file
- batch/shell scripts necessary for development and merging (in `projectscripts/`)
- Its [g3man](https://github.com/skirlez/g3man/) mod definition and patches (in `mod/`)

## Installing
The recommended way to install Endless Void is through g3man. I haven't actually gotten to making profile distribution work. When I do that I'll have to change this part of the README.

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
The code is licensed under the terms of the AGPLv3.

## Contributing
Please contribute
