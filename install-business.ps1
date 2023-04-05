$ErrorActionPreference = "Stop"

$CONFIG = "windows-business.conf.yml"
$DOTBOT_DIR = "dotbot"

$DOTBOT_BIN = "bin/dotbot"
$BASEDIR = $PSScriptRoot

Set-Location $BASEDIR
git -C $DOTBOT_DIR submodule sync --quiet --recursive
git submodule update --init --recursive $DOTBOT_DIR

[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
$result = [System.Windows.Forms.MessageBox]::Show('Are you have made a backup before?' , "Info" , 4)
if ($result -eq 'Yes') {
    foreach ($PYTHON in ('python', 'python3', 'python2')) {
        # Python redirects to Microsoft Store in Windows 10 when not installed
        if (& { $ErrorActionPreference = "SilentlyContinue"
                ![string]::IsNullOrEmpty((&$PYTHON -V))
                $ErrorActionPreference = "Stop" }) {
            &$PYTHON $(Join-Path $BASEDIR -ChildPath $DOTBOT_DIR | Join-Path -ChildPath $DOTBOT_BIN) -d $BASEDIR -c $CONFIG $Args
            return
        }
    }
    Write-Error "Error: Cannot find Python."
}

Write-Host "After Installation, please have a look at the output. It can be, that some symlinks are not creted" -ForegroundColor Yellow
Write-Host "If so, please remove the mentioned files and run the script again" -ForegroundColor Yellow
Write-Host "If symlinking for Windows Terminal can't created, so Windows Terminal is in use" -ForegroundColor Yellow
Write-Host "Please close it, remove the settings file and run the script from PowerShell ISE again" -ForegroundColor Yellow
