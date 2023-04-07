#
# dotfiles : https://github.com/saigkill/dotfiles
#
# Script to bootstrap a Windows private box
#
# Authors:
#   Sascha Manns <Sascha.Manns@outlook.de>
#   Edi Wang <edi.wang@outlook.com>

# Variables
$GoVersion = "1.18"
$DotNetSDKVersion = "7"
$VisualStudioVersion = "2022"
$LinqPadVersion = "7"
$OpenJDKVersion = "11"
$PythonVersion = "3.10"

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

function Check-Command($cmdname) {
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

function AddToPath {
    param (
        [string]$folder
    )

    Write-Host "Adding $folder to environment variables..." -ForegroundColor Yellow

    $currentEnv = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine).Trim(";");
    $addedEnv = $currentEnv + ";$folder"
    $trimmedEnv = (($addedEnv.Split(';') | Select-Object -Unique) -join ";").Trim(";")
    [Environment]::SetEnvironmentVariable(
        "Path",
        $trimmedEnv,
        [EnvironmentVariableTarget]::Machine)

    #Write-Host "Reloading environment variables..." -ForegroundColor Green
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

function Remove-UWP {
    param (
        [string]$name
    )

    Write-Host "Removing UWP $name..." -ForegroundColor Yellow
    Get-AppxPackage $name | Remove-AppxPackage
    Get-AppxPackage $name | Remove-AppxPackage -AllUsers
}

# -----------------------------------------------------------------------------
Write-Host "OS Info:" -ForegroundColor Green
Get-CimInstance Win32_OperatingSystem | Format-List Name, Version, InstallDate, OSArchitecture
(Get-ItemProperty HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor\0\).ProcessorNameString

Write-Host ""
Write-Host "You have hardcoded the following versions:" -ForegroundColor Green
Write-Host "Go Version: $GoVersion" -ForegroundColor Green
Write-Host "DotNet SDK Version: $DotNetSDKVersion" -ForegroundColor Green
Write-Host "Visual Studio Version: $VisualStudioVersion" -ForegroundColor Green
Write-Host "LinqPad Version: $LinqPadVersion" -ForegroundColor Green
Write-Host "OpenJDK Version: $OpenJDKVersion" -ForegroundColor Green
Write-Host "Python Version: $PythonVersion" -ForegroundColor Green

$msg = 'Do you want to use this settings? [Y/N]'
do {
    $response = Read-Host -Prompt $msg
    if ($response -eq 'y') {
        Write-Host "Using this settings." $computerName  -ForegroundColor Yellow
    }
} until ($response -eq 'n') {
    Write-Host "Breaking script..." -ForegroundColor Red
    break
}

# -----------------------------------------------------------------------------
$msg = 'Do you want to rename the computer? [Y/N]'
do {
    $response = Read-Host -Prompt $msg
    if ($response -eq 'y') {
        $computerName = Read-Host 'Enter New Computer Name'
        Write-Host "Renaming this computer to: " $computerName  -ForegroundColor Red
        Rename-Computer -NewName $computerName
    }
} until ($response -eq 'n')

# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "Disable Sleep on AC Power..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Powercfg /Change monitor-timeout-ac 20
Powercfg /Change standby-timeout-ac 0

# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "Add 'This PC' Desktop Icon..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
$thisPCIconRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
$thisPCRegValname = "{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
$item = Get-ItemProperty -Path $thisPCIconRegPath -Name $thisPCRegValname -ErrorAction SilentlyContinue
if ($item) {
    Set-ItemProperty  -Path $thisPCIconRegPath -name $thisPCRegValname -Value 0
}
else {
    New-ItemProperty -Path $thisPCIconRegPath -Name $thisPCRegValname -Value 0 -PropertyType DWORD | Out-Null
}
# -----------------------------------------------------------------------------
# To list all appx packages:
# Get-AppxPackage | Format-Table -Property Name,Version,PackageFullName
Write-Host "Removing UWP Rubbish..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
$uwpRubbishApps = @(
"Microsoft.MSPaint"
"Microsoft.Microsoft3DViewer"
"Microsoft.ZuneMusic"
"Microsoft.ZuneVideo"
"*549981C3F5F10*"
"Microsoft.WindowsSoundRecorder"
"Microsoft.PowerAutomateDesktop"
"Microsoft.BingWeather"
"Microsoft.BingNews"
"king.com.CandyCrushSaga"
"Microsoft.Messaging"
"Microsoft.WindowsFeedbackHub"
"Microsoft.MicrosoftOfficeHub"
"Microsoft.MicrosoftSolitaireCollection"
"Microsoft.GetHelp"
"Microsoft.People"
"Microsoft.Microsoft3DViewer"
"Microsoft.WindowsMaps"
"Microsoft.MixedReality.Portal"
"Microsoft.SkypeApp")

foreach ($uwp in $uwpRubbishApps) {
    Remove-UWP $uwp
}
# -----------------------------------------------------------------------------

$msg = 'Do you want to install IIS? [Y/N]'
do {
    $response = Read-Host -Prompt $msg
    if ($response -eq 'y') {
        Write-Host ""
        Write-Host "Installing IIS..." -ForegroundColor Green
        Write-Host "------------------------------------" -ForegroundColor Green
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-DefaultDocument -All
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpCompressionDynamic -All
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpCompressionStatic -All
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebSockets -All
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-ApplicationInit -All
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-ASPNET45 -All
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-ServerSideIncludes
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-BasicAuthentication
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-WindowsAuthentication
    }
} until ($response -eq 'n')

# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "Enable Microsoft Subsystem for Linux..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "Enable Windows 10 Developer Mode..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowDevelopmentWithoutDevLicense" /d "1"

# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "Enable Remote Desktop..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\" -Name "fDenyTSConnections" -Value 0
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\" -Name "UserAuthentication" -Value 1
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# -----------------------------------------------------------------------------
Write-Host "Preparing to install Chocolatey and Scoop..." -ForegroundColor Green
# -----------------------------------------------------------------------------
if (Check-Command -cmdname 'choco') {
    Write-Host "Choco is already installed, skip installation."
}
else {
    Write-Host ""
    Write-Host "Installing Chocolate for Windows..." -ForegroundColor Green
    Write-Host "------------------------------------" -ForegroundColor Green
    Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

if (Check-Command -cmdname 'scoop') {
    Write-Host "Scoop is already installed, skip installation."
}
else {
    Write-Host ""
    Write-Host "Installing Scoop for Windows..." -ForegroundColor Green
    Write-Host "------------------------------------" -ForegroundColor Green
    Set-ExecutionPolicy Bypass -Scope Process -Force; irm get.scoop.sh | iex
    AddToPath -folder "$env:USERPROFILE\scoop\shims"
}
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "Installing Applications..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green

# The next apps in list jsut having an store id. It is in the following order:
# UnRar, Nuget Package Explorer, XAML Asset Explorer, WSA Tools, DevToys, Adobe Express,
# Adobe Photoshop Express, Pichon Icons, Sysinternals Suite, XAML Studio,
# Raft WSL, GWSL, Instagram, Pengwin, Prime Video, Amazon Appstore
# Windows Terminal
$WingetStoreApps = @(
"9PKGXJZ3XVBV",
"9WZDNCRDMDM3",
"9P8WCWPN2S5C",
"9N4P75DXL6FG",
"9PGCV4V3BK4W",
"9P94LH3Q1CP5",
"9WZDNCRFJ27N",
"9NK8T1KSHFFR",
"9P7KNL5RWT25",
"9NTLS214TKMQ",
"9MSMJQD017X7",
"9NL6KD1H33V3",
"9NBLGGH5L9XT",
"9N5LW3JBCXKF",
"9NV1GV1PXZ6P",
"9P6RC76MSMMJ",
"9NJHK44TTKSX",
"9N0DX20HK701"
)
Write-Host "The installed Amazon Appstore also enables Windows Subsystem for Android..." -ForegroundColor Green

foreach ($app in $WingetStoreApps) {
    winget install --id $app
}

$WingetPreindexedApps = @(
"Microsoft.BotFrameworkEmulator",
"Microsoft.VisualStudio.$VisualStudioVersion.Enterprise.Preview",
"7zip.7zip",
"ScooterSoftware.BeyondCompare4",
"Docker.DockerDesktop",
"Nikkho.FileOptimizer",
"Git.Git",
"GnuPG.GnuPG",
"GnuPG.Gpg4win",
"Greenshot.Greenshot",
"JesseDuffield.Lazydocker",
"JesseDuffield.lazygit",
"KDE.KDiff3",
"Microsoft.Azure.StorageEmulator",
"Microsoft.Edge.Dev",
"Ngrok.Ngrok",
"Insecure.Nmap",
"Notepad++.Notepad++",
"OBSProject.OBSStudio",
"JanDeDobbeleer.OhMyPosh",
"Evolus.Pencil",
"Postman.Postman",
"Valve.Steam",
"Microsoft.Teams",
"GitHub.GitHubDesktop",
"IrfanSkiljan.IrfanView",
"JetBrains.Toolbox",
"vim.vim",
"WinDirStat.WinDirStat",
"WinMerge.WinMerge",
"DigitalScholar.Zotero",
"Microsoft.BotFrameworkComposer",
"DimitriVanHeesch.Doxygen",
"PenguinLabs.Cacher",
"SlackTechnologies.Slack",
"Keybase.Keybase",
"Microsoft.DotNet.SDK.$DotNetSDKVersion",
"GitHub.cli",
"Microsoft.Azure.FunctionsCoreTools",
"Microsoft.WindowsSDK",
"Amazon.Games",
"Microsoft.PowerToys",
"DBBrowserForSQLite.DBBrowserForSQLite",
"opticos.openinwsl",
"EpicGames.EpicGamesLauncher",
"GOG.Galaxy",
"RicoSuter.NSwagStudio",
"StefansTools.grepWin",
"LINQPad.LINQPad.$LinqPadVersion",
"OpenJS.NodeJS",
"calibre.calibre",
"Microsoft.Azure.StorageExplorer",
"Microsoft.PowerShell",
"AOMEI.Backupper",
"gerardog.gsudo",
"Rustlang.Rust.MSVC",
"Microsoft.AzureCLI",
"MarekJasinski.FreeCommanderXE",
"GoLang.Go.$GoVersion",
"Caphyon.AdvancedInstaller",
"aluxnimm.outlookcaldavsynchronizer",
"Zoom.Zoom",
"Microsoft.OpenJDK.$OpenJDKVersion",
"Intel.IntelDriverAndSupportAssistant",
"Python.Python.$PythonVersion",
"Microsoft.GitCredentialManagerCore",
"Gyan.FFmpeg",
"JernejSimoncic.Wget",
"Microsoft.AppInstallerFileBuilder",
"Microsoft.AzureDataStudio",
"sfx101.deck",
"dotPDNLLC.paintdotnet",
"SomePythonThings.WingetUIStore"
)

foreach ($app in $WingetPreindexedApps) {
    winget install $app
}
AddToPath -folder "$env:ProgramFiles\Vim\vim90"
AddToPath -folder "$env:ProgramFiles\GnuPG\bin"

# Install with choco
$ChocoApps = @(
"nuget.commandline",
"filezilla",
"aria2",
"bat",
"chocolatey-compatibility.extension",
"chocolatey-core.extension",
"chocolatey-windowsupdate.extension",
"less",
"neovim",
"onecommander",
"sophiapp",
"sqlitestudio")

foreach ($app in $ChocoApps) {
    choco install $app -y
}

# Install with scoop
$ScoopApps = @(
"bluescreenview",
"currports",
"database.net",
"fd",
"fiddler",
"findutils",
"fzf",
"grep",
"gtools",
"lazydocker",
"lazygit",
"produkey",
"regscanner",
"ripgrep",
"topgrade"
)

scoop bucket add nirsoft
scoop bucket add extras
scoop bucket add java
scoop bucket add main
scoop bucker add games
scoop bucket add nerd-fonts

foreach ($app in $ScoopApps) {
    scoop install $app
}

# ------------------------------------------------------------
Write-Host "Downloading and installing apps..." -ForegroundColor Green
$DownloadedAppMSI = @(
"https://sipgate-faxdrucker.s3.eu-central-1.amazonaws.com/SipgateFaxdruckerInstall_x64.msi"
)
foreach ($app in $DownloadedAppsMSI) {
    $filename = $app.split("/")[-1]
    $filepath = "$env:USERPROFILE\Downloads\$filename"
    if (!(Test-Path $filepath)) {
        Write-Host "Downloading $app"
        Invoke-WebRequest -Uri $app -OutFile $filepath
        Start-Process $filepath -Wait
    }
}

$DownloadedAppExe = @(
"https://cdn.stardock.us/downloads/public/software/objectdesktop/objectdesktop_setup.exe",
"http://sourceforge.net/projects/texniccenter/files/TeXnicCenter/2.02%20Stable/TXCSetup_2.02Stable_x64.exe/download"
)
foreach ($app in $DownloadedAppsExe) {
    $filename = $app.split("/")[-1]
    $filepath = "$env:USERPROFILE\Downloads\$filename"
    if (!(Test-Path $filepath)) {
        Write-Host "Downloading $app"
        Invoke-WebRequest -Uri $app -OutFile $filepath
        Invoke-Expression -Command $filepath
    }
}

$ManualApps = @(
"Docutain on: https://www.docutain.de/",
"Entity Developer Express on: https://marketplace.visualstudio.com/items?itemName=DevartSoftware.EntityDeveloperExpress",
"Innovasys Document X on: https://www.innovasys.com/product/",
"Lexware Finanzmnanager on: https://www.lexware.de/",
"Norton 360, Norton Utilities on: https://de.norton.com/",
"Oxygen XML Editor on: https://www.oxygenxml.com/",
"Syncfusion Essentials on: https://www.syncfusion.com/account/downloads",
"Syncfusion Metro Studio on: https://www.syncfusion.com/downloads/metrostudio/",
"Taxman on: https://download.taxman.de/2023"
)
Write-Host "The following apps need to be downloaded and  installed manually:" -ForegroundColor Purple
foreach ($app in $ManualApps) {
    Write-Host $app -ForegroundColor Purple
}

#------------------------------------------------------------------------------
$regex = "^#|^$" #Regex for filtering
$poshmod = 'Install-Module'
Write-Host ""
Write-Host "Installing Powershell Modules..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
if (Test-Path -Path $pwd\packages\powershell-modules){
    foreach($line in Get-Content $pwd\packages\powershell-modules){
        if ($line -notmatch $regex){
            $poshargs = ' ' + $line
            Start-Process -FilePath $poshmod -ArgumentList $poshargs -NoNewWindow
        }
    }
}
AddToPath "$env:USERPROFILE\AppData\Local\Programs\oh-my-posh\bin"

#------------------------------------------------------------------------------
Write-Host ""
Write-Host "Installing Typescript globally..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
npm install -g typescript

#------------------------------------------------------------------------------
Write-Host ""
Write-Host "Installing Dotnet tools globally..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
dotnet tool install -g dotnet-ef
dotnet workload install macos maccatalyst ios maui-android android maui-windows maui-ios maui-maccatalyst wasm-tools

AddToPath "$env:USERPROFILE\.dotnet\tools"
#-----------------------------------------------------------------------------

# Android CLI
if ($true) {
    Write-Host "Downloading Android-Platform-Tools (To connect to Android Phone)..." -ForegroundColor Green
    Write-Host "------------------------------------" -ForegroundColor Green
    $toolsPath = "${env:ProgramFiles}\Android-Platform-Tools"
    $downloadUri = "https://dl.google.com/android/repository/platform-tools-latest-windows.zip"

    $downloadedTool = $env:USERPROFILE + "\platform-tools-latest-windows.zip"
    Remove-Item $downloadedTool -ErrorAction SilentlyContinue
    aria2c.exe $downloadUri -d $HOME -o "platform-tools-latest-windows.zip"

    & ${env:ProgramFiles}\7-Zip\7z.exe x $downloadedTool "-o$($toolsPath)" -y
    AddToPath -folder "$toolsPath\platform-tools"
    Remove-Item -Path $downloadedTool -Force
}

# Kubernetes CLI
if ($true) {
    Write-Host "Downloading Kubernetes CLI..." -ForegroundColor Green
    Write-Host "------------------------------------" -ForegroundColor Green
    $toolsPath = "${env:ProgramFiles}\Kubernetes"
    $downloadUri = "https://dl.k8s.io/release/v1.25.0/bin/windows/amd64/kubectl.exe"

    $downloadedTool = $env:USERPROFILE + "\kubectl.exe"
    Remove-Item $downloadedTool -ErrorAction SilentlyContinue
    aria2c.exe $downloadUri -d $HOME -o "kubectl.exe"

    New-Item -Type Directory -Path "${env:ProgramFiles}\Kubernetes" -ErrorAction SilentlyContinue
    Move-Item $downloadedTool "$toolsPath\kubectl.exe" -Force
    AddToPath -folder $toolsPath
}

# ------------------------------------------------------------
Write-Host "Avoid rubbish folder grouping..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
(gci 'HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags' -s | ? PSChildName -eq '{885a186e-a440-4ada-812b-db871b942259}' ) | ri -Recurse

# ------------------------------------------------------------
Write-Host "Applying file explorer settings..." -ForegroundColor Green
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideFileExt /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v AutoCheckSelect /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v LaunchTo /t REG_DWORD /d 1 /f"

# ------------------------------------------------------------
Write-Host "Disabling the Windows Ink Workspace..." -ForegroundColor Green
REG ADD "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\PenWorkspace" /V PenWorkspaceButtonDesiredVisibility /T REG_DWORD /D 0 /F

# ------------------------------------------------------------
Write-Host "Exclude repos from Windows Defender..." -ForegroundColor Green
Add-MpPreference -ExclusionPath "$env:USERPROFILE\OneDrive\workspace\repos"
Add-MpPreference -ExclusionPath "$env:USERPROFILE\.nuget"
Add-MpPreference -ExclusionPath "$env:USERPROFILE\.vscode"
Add-MpPreference -ExclusionPath "$env:USERPROFILE\.dotnet"
Add-MpPreference -ExclusionPath "$env:USERPROFILE\.ssh"
Add-MpPreference -ExclusionPath "$env:USERPROFILE\.azuredatastudio"
Add-MpPreference -ExclusionPath "$env:APPDATA\npm"
Add-MpPreference -ExclusionPath "$NextcloudPath"

# ------------------------------------------------------------
Write-Host "Enabling dark theme..." -ForegroundColor Green
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name AppsUseLightTheme -Value 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name SystemUsesLightTheme -Value 0
Write-Host "Dark theme enabled."

# ------------------------------------------------------------
Write-Host "Syncing time..." -ForegroundColor Green
net stop w32time
net start w32time
w32tm /resync /force
w32tm /query /status

Write-Host "Setting Time zone..." -ForegroundColor Green
Set-TimeZone -Name "W. Europe Standard Time"

# ------------------------------------------------------------
Write-Host "Enabling Hardware-Accelerated GPU Scheduling..." -ForegroundColor Green
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\" -Name 'HwSchMode' -Value '2' -PropertyType DWORD -Force

# ------------------------------------------------------------
Write-Host "Addding 'Run as Administrator' to context menu..." -ForegroundColor Green
reg.exe import ../windows-registry/Add_PS1_Run_as_administrator.reg

# ------------------------------------------------------------
Write-Host "Installing Github.com/microsoft/artifacts-credprovider..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/microsoft/artifacts-credprovider/master/helpers/installcredprovider.ps1'))

# ------------------------------------------------------------
Write-Host "Removing Bluetooth icons..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
cmd.exe /c "reg add `"HKCU\Control Panel\Bluetooth`" /v `"Notification Area Icon`" /t REG_DWORD /d 0 /f"

# ------------------------------------------------------------
$msg = 'Do you want to install dotfiles? [Y/N]'
do {
    $response = Read-Host -Prompt $msg
    if ($response -eq 'y') {
        Write-Host "Installing dotfiles." $computerName  -ForegroundColor Yellow
        $pathToDotfilesInstaller = "..\install-private.ps1"
        Invoke-Expression $pathToDotfilesInstaller
        AddToPath -folder "$env:USERPROFILE\bin\powershell"
    }
} until ($response -eq 'n') {
    Write-Host "Skip installing dotfiles..." -ForegroundColor Yellow
}

# ------------------------------------------------------------
# Install Awesome Windows Terminal Fonts
$awesomedir = '../awesome-windows-terminal-fonts'
Start-Process -FilePath "$awesomedir/install.ps1" -ArgumentList -NoNewWindow -Wait
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "Checking Windows updates..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Install-Module -Name PSWindowsUpdate -Force
Write-Host "Installing updates... (Computer will reboot in minutes...)" -ForegroundColor Green
Get-WindowsUpdate -AcceptAll -Install -ForceInstall -AutoReboot

# -----------------------------------------------------------------------------
Write-Host "------------------------------------" -ForegroundColor Green
Read-Host -Prompt "Setup is done, restart is needed, press [ENTER] to restart computer."
Restart-Computer
