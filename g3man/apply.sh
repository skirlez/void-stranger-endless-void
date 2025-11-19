source package.sh


if [ -z "$GAME_PATH" ]; then
  echo "Could not apply the mod:"
  echo "GAME_PATH is unset. In order for the script to apply your mod, it should know where the game directory is."
  exit 1
fi

if [ -z "$CLEAN_DATAFILE_PATH" ]; then
  echo "Could not apply the mod:"
  echo "CLEAN_DATAFILE_PATH is unset. In order for the script to apply your mod, it needs the game's unmodified datafile."
  exit 1
fi

if [ -z "$GAME_DATAFILE_NAME" ]; then
  echo "Could not apply the mod:"
  echo "GAME_DATAFILE_NAME is unset. Please set it to the name you'd like the datafile to have in GAME_PATH."
  exit 1
fi

if [ -z "$G3MAN_PATH" ]; then
  echo "Could not apply the mod:"
  echo "G3MAN_PATH is unset. In order for the script to apply your mod, it needs g3man."
  exit 1
fi

dotnet "$G3MAN_PATH" apply profile \
    --path "out" \
    --datafile "$CLEAN_DATAFILE_PATH" \
    --out="$GAME_PATH" \
    --outname="$GAME_DATAFILE_NAME"