#!/usr/bin/env bash

# Shell script to remove Void Stranger assets from Endless Void

if [ ! -f "variables.sh" ]; then
  cp .variables.structure.sh variables.sh
  echo "variables.sh created. Please fill in all of the empty variables, then rerun this script."
  exit 1
fi

source variables.sh

cd "$EV_PROJECT_PATH/projectscripts"

if [ -z "$EV_PROJECT_PATH" ] || [ -z "$UNDERTALEMODCLI_PATH" ] || [ -z "$VOID_STRANGER_PATH" ]; then
    echo "Some variables are empty. Please fill in all of the variables."
    exit 1
fi

echo "Please make sure the data.win in $VOID_STRANGER_PATH is not modified before proceeding."
read -p "Continue? (y/n): " answer
if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
  $UNDERTALEMODCLI_PATH load "$VOID_STRANGER_PATH/data.win" --scripts "./csx/cleaner.csx"
fi

