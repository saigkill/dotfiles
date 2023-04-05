##!/usr/bin/env bash

# Terminate running polybars
killall -q polybar

primary=$(polybar --list-monitors | grep "primary" | cut -d":" -f1)

for m in $(polybar --list-monitors | cut -d":" -f1); do
	MONITOR=$m polybar --reload default-bar &
	if [[ "$XDG_CURRENT_DESKTOP" != "KDE" && "$m" == "$primary" ]]; then
		MONITOR=$m polybar --reload tray-bar &
	fi
done
