## /mod folder

This folder contains:

`copy-vs-assets.csx` - This is an UndertaleModTool/Cli script that copies graphics and audio data from Void Stranger into the Endless Void source tree. You can't actually build the game without doing this.

It expects you to run the script on Void Stranger's data.win, and expects you to do so from *this folder*. TODO: Should probably have it ask for input.

`.variables.sh` - Defines several things in the build process unique to your system (Game directory, GameMaker user folder.) If it does not exist, please copy and rename `.variables.structure.sh` to `.variables.sh`. The file is ignored by git.

`build.sh` - Builds the mod and copies the output data.win to `igor/mod_data.win`

`package-as-standalone.sh` - Builds the mod, and packages it as a standalone g3man mod, with the output mod folder being in `out/mod`. The output folder is composed of the `base` folder, with `igor/mod_data.win` copied in.

`package-as-profile.sh` - Builds the mod, and packages it as a g3man profile, with the output profile folder being in `out/profile`. The profile folder copies everything `base-profile`, which should contain the `profile.json` that defines the profile,
and any other mods that you want to be included in the final profile folder. Additionally, the `base` folder is copied into the output profile folder.
