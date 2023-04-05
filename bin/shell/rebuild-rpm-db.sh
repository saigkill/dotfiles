#!/bin/bash
# (c) 2015 Sascha Manns <Sascha.Manns@outlook.de>
# Script for openSUSE cleans the zypper cache and rebuilds the package database
zypper clean -a && zypper ref && rpm --rebuilddb
