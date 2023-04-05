# (c) 2021 Sascha Manns <Sascha.Manns>
# Checks if there are problems in filesystem
# If found issues uncomment last line
sudo wmic diskdrive
sudo sfc /scannow
sudo chkdsk /i
# Wenn beschädigt
# sudo chkdsk /r