# Endless Void
Endless Void is a fully functional level builder for Void Stranger. 

You can create your own levels with it, and upload them to a server (a [Voyager](https://github.com/hexfae/voyager) instance).

You can also build non-linear level packs.

This repository contains:
- Its GameMaker project file
- Its [g3man](https://github.com/skirlez/g3man/) mod definition, build scripts, and patches (in `g3man/`)

## Installing
Go to the [Releases](https://github.com/skirlez/void-stranger-endless-void/releases) page, and follow the installation guide for the release you want.

## Building
See [Building Endless Void](https://github.com/Skirlez/void-stranger-endless-void/wiki/Building-Endless-Void-(Windows)) on the Wiki

## Things of note about the code
- Indices of objects, sprites, sounds, etc. become mismatched when merging with Void Stranger, so references to them are always obtained with `asset_get_index()`/`agi()`.
- Semicolons are lightly and inconsistently sprinkled throughout, because of muscle memory, but GameMaker does not enforce them...
- It's uh, pretty good, semi-occasionally.

## License
The code is licensed under the terms of the AGPLv3.

## Contributing
Please contribute
