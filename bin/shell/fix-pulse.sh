#!/bin/bash
# (c) 2011 Sascha Manns <saigkill@opensuse.org>
# This script just sets a+rw rights on the snd device. Because of a bug in openSUSE it should executed by login, to get pulseaudio working.
sudo chmod a+rw /dev/snd/*
