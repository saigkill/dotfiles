#!/bin/bash
# (c) 2014 Sascha Manns <Sascha.Manns@outlook.de>
# This script clears the ram cache and the swap
su -c "echo 3 >'/proc/sys/vm/drop_caches' && swapoff -a && swapon -a && printf '\n%s\n' 'Ram-cache and Swap Cleared'" root
