# (c) 2021 Sascha Manns <Sascha.Manns@outlook.de>
# Script for a network reset under Windows
netsh winsock reset
netsh int ip reset
ipconfig /renew
ipconfig /flushdns
netcfg -d