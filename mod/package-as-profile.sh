#!/usr/bin/env bash

if [ ! -f "./profile.json" ]; then
	echo "In order to package the mod as a profile, make a profile.json first!"
	exit 1
fi

source build.sh

echo "Creating profile folder..."



if [ ! -d "./out/profile" ]; then
  mkdir -p ./out/profile
fi
rsync -a --delete ./base ./out/profile
cp ./igor/mod_data.win ./out/profile/base
cp ./profile.json ./out/profile

echo Done!