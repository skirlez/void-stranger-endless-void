## /mod folder

This folder contains:

`copy-game-assets.csx` - This is an UndertaleModTool/Cli script that copies graphics and audio data from Void Stranger into the Endless Void source tree. You can't actually build the game without doing this.

It expects you to run the script on Void Stranger's data.win, and expects you to do so from *this folder*. TODO: Should probably have it ask for input.

`user-config.ini` - Defines several things in the build process unique to your system (Game directory, GameMaker user folder.) If it does not exist, run any of the scripts below and it will be created for you.
(or copy and rename `".user-config-template.ini"`)

Then there are .py Python files. To run them, please install [Python](https://www.python.org/) on your system. Any 3.1x version should work, and if they don't, open an issue.

`build.py` - Builds the mod and copies the output data.win to `igor/mod_data.win`

`package.py` - Builds the mod, and packages it as a g3man profile, with the output profile folder being in `out`.
`out` copies everything from `base`, which should contain your mod's folder along with a `profile.json`.
and any other mods that you want to be included in the final profile folder. Additionally, the `base` folder is copied into the output profile folder.

`apply.py` - Builds and packages the mod, then calls g3man to apply it for you.