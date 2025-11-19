## The files with `structure` in the name exist to be templates.
## This file should be copied and renamed to `variables.sh` for the rest of the scripts to be able to read it!

## Do not include a `/` or `\` at the end of any of the variables, including when filling in folder paths.


# You may set this variable to 0 if your project doesn't have a GameMaker project.
# If set to 0, you don't need to fill in any variables labeled as required for building only.
BUILD_PROJECT=1


# (REQUIRED FOR BUILDING ONLY)
# Linux: Likely is /home/USER/.local/share/GameMakerStudio2/Cache
# Windows: Likely is C:\ProgramData\GameMakerStudio2\Cache
GAMEMAKER_CACHE_PATH=""

# (REQUIRED FOR BUILDING ONLY)
# The runtime version to look for in the GameMaker cache. 
# This is the version you have to download using the IDE.
RUNTIME_VERSION="2023.4.0.113"

# (REQUIRED FOR BUILDING ONLY)
# Linux: Likely is /home/USER/.config/GameMakerStudio2/user_somenumbers
# Windows: Likely is C:\Users\USER\AppData\Roaming\GameMakerStudio2\user_somenumbers
USER_DIRECTORY_PATH=""

# (REQUIRED FOR BUILDING ONLY)
# Set the project configuration to be used when building. 
# Endless Void uses this to not include any sprites or audio from Void Stranger in the output datafile,
# saving compilation time (since said sprites and audio will exist in the final merged datafile)
GAMEMAKER_CONFIGURATION="NoVoidStrangerGroups"

# (REQUIRED FOR BUILDING ONLY)
# The name of the project (the .yyp filename)
PROJECT_NAME="void-stranger-endless-void"

# Path to the game's clean datafile.
# You can reuse g3man/g3man_clean_data.win if you have it.
# I recommend copying it to the same folder as the script. Git is set to ignore it.
CLEAN_DATAFILE_PATH=""

# Path to where the game is.
GAME_PATH=""

# This'll be data.win for windows, or game.unx for example on Linux.
# Note that if you are using Proton on Steam for example, this will use the windows name.
GAME_DATAFILE_NAME="data.win"

# Path to the g3man executable
G3MAN_PATH=""

