#!/usr/bin/env bash

source build.sh

if [ ! -f "./base-profile/profile.json" ]; then
	echo "In order to package the mod as a profile, make a profile.json in the base-profile first!"
	exit 1
fi

echo "Creating profile folder..."

if [ ! -d "./out/profile" ]; then
  mkdir -p ./out/profile
fi
rsync -a --delete ./base-profile/ ./out/profile
rsync -a --delete ./base ./out/profile
cp ./igor/mod_data.win ./out/profile/base

echo Done! Profile folder is in out/profile.