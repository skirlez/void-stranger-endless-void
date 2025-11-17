#!/usr/bin/env bash

# Shell script to build a mod's GameMaker project and merge it with the game using g3man

# TODO: hash build inputs, skip if already built

if [ ! -f "variables.sh" ]; then
  cp .variables.structure.shell variables.sh
  echo "variables.sh created. Please fill in all of the empty variables, then rerun this script."
  exit 1
fi

echo "Reading variables.sh"
source variables.sh

if [ -z "$GAMEMAKER_CACHE_PATH" ] || [ -z "$USER_DIRECTORY_PATH" ] || [ -z "$PROJECT_NAME" ] || [ -z "$G3MAN_PATH" ] || [ -z "$GAME_PATH" ]; then
    echo "Could not build EV:"
    echo "Some variables are empty. Please fill in all of the variables."
    exit 1
fi

cd "./igor"

if [ -d "./output" ]; then
  echo "Removing output folder and zip"
  rm -rf ./output
  rm void-stranger-endless-void.zip
fi

IGOR_PATH="$GAMEMAKER_CACHE_PATH/runtimes/runtime-2023.4.0.113/bin/igor/linux/x64/Igor"
RUNTIME_PATH="$GAMEMAKER_CACHE_PATH/runtimes/runtime-2023.4.0.113"

if [ -f "./data.win" ]; then
  echo "Removing old data.win"
  rm ./data.win
fi

echo "------------------------------------"
echo "Building the mod's GameMaker project"
echo "------------------------------------"

$IGOR_PATH \
    -j=8 \
    --user="$USER_DIRECTORY_PATH" \
    --project="../../$PROJECT_NAME.yyp" \
    --config="NoVoidStrangerGroups" \
    --runtimePath="$RUNTIME_PATH" \
    --tf="mod-package.zip" \
    --temp="./igor-temp/" \
    -- Linux Package

cp "./output/void-stranger-endless-void/package/assets/game.unx" mod_data.win
if [ $? -eq 0 ]; then
    echo "Building finished."
else
    echo "Could not build EV:"
    echo "Something failed. Could not find game.unx."
    exit 1
fi

if [ -d "./output" ]; then
  echo "Removing output folder and zip"
  rm -rf ./output
fi

if [ -f "./mod-package.zip" ]; then
  rm mod-package.zip
fi

cd ..

echo Done!
