#!/usr/bin/bash
git rm "$1"
rm -rf ".git/modules/$1"
git config -f ".git/config" --remove-section "submodules.$1" 2> /dev/null
git commit -m "Remove submodule $1"