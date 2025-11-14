#!/usr/bin/env bash

source build.sh

echo "Creating mod folder..."


if [ ! -d "./out/mod" ]; then
  mkdir -p ./out/mod
fi
rsync -a --delete ./base ./out/profile
cp ./igor/mod_data.win ./out/profile/base

echo Done!