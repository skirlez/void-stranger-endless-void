#!/usr/bin/env bash

source "variables.sh"

echo "Creating profile folder..."

if [ ! -d out ]; then
  mkdir out
fi
rsync -a --delete ./base/ ./out

cp igor/mod_data.win out/mod

echo "Done! The packaged profile folder is in out."