#!/usr/bin/env bash

# Shell script to build a mod's GameMaker project and merge it with the game using g3man

# TODO: hash build inputs, skip if already built

if [ ! -f "variables.sh" ]; then
  cp .variables.structure.shell variables.sh
  echo "variables.sh created. Please fill in all of the empty variables, then rerun this script."
  exit 1
fi

echo "Reading variables.sh"
source ./variables.sh


if [[ $BUILD_PROJECT == 0 ]]; then
  echo "Skipping building..."
  exit 0
fi

if [ -z "$PROJECT_NAME" ] || [ -z "$GAMEMAKER_CACHE_PATH" ] || [ -z "$RUNTIME_VERSION" ] || [ -z "$USER_DIRECTORY_PATH" ] || [ -z "$GAMEMAKER_CONFIGURATION" ]; then
  echo "Could not build the mod:"
  echo "BUILD_PROJECT is set to 1, but some variables required for building are empty. Please fill in all of the variables."
  exit 1
fi


PROJECT_YYP="$(realpath ../$PROJECT_NAME.yyp)"
if [ ! -f "$PROJECT_YYP" ]; then
	echo "Your GameMaker project should be in $PROJECT_YYP, as per the PROJECT_NAME specified in your variables.sh, but no such file was found."
  exit 1
fi

if [ ! -d "./igor" ]; then
  mkdir ./igor
fi

cd "./igor"

if [ -d "./output" ]; then
  echo "Removing output folder and zip"
  rm -rf ./output
fi

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  IGOR_OS_SUBFOLDER="linux"
  IGOR_TARGET="Linux Package"
  IGOR_OUTPUT_PATH="package/assets/game.unx"
else
  # assume windows lol
  IGOR_OS_SUBFOLDER="windows"
  IGOR_OUTPUT_PATH="data.win"
  IGOR_TARGET="Windows PackageZip"
fi

IGOR_PATH="$GAMEMAKER_CACHE_PATH/runtimes/runtime-$RUNTIME_VERSION/bin/igor/$IGOR_OS_SUBFOLDER/x64/Igor"
RUNTIME_PATH="$GAMEMAKER_CACHE_PATH/runtimes/runtime-$RUNTIME_VERSION"


echo "------------------------------------"
echo "Building the mod's GameMaker project"
echo "------------------------------------"

$IGOR_PATH \
    -j=8 \
    --user="$USER_DIRECTORY_PATH" \
    --project="$PROJECT_YYP" \
    --config="NoVoidStrangerGroups" \
    --runtimePath="$RUNTIME_PATH" \
    --tf="mod-package.zip" \
    --temp="./igor-temp/" \
    -- $IGOR_TARGET

cp "./output/void-stranger-endless-void/$IGOR_OUTPUT_PATH" mod_data.win
if [ $? -eq 0 ]; then
    echo "Building finished."
else
    echo "Could not build the mod:"
    echo "Something failed. Could not find $IGOR_OUTPUT_PATH"
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
