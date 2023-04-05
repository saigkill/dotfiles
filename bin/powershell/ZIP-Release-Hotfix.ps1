# Dieses Script erstellt ein ZIP-File aus dem aktuellen DEV-Release Build-Target.
# (c) 2021 by Sascha Manns

# Hardcoded stuff
$Version:1.0
$Username = $env:USERNAME
# Hier kannst du den Pfad zu deinem Release-Ordner eintragen
$SourcePath = 'C:\Users\' + $Username + '\source\repos\unicorn2\Unicorn2\bin\Release'
$SolutionPath = 'C:\Users' + $Username + '\source\repos\unicorn2\Unicorn2.sln'
# Hier trägst du den Zielpfad für das PDF ein
$DestinationPath = 'Y:\Unicorn Versionen\' + $Username + '-hotfix\' + $Username + '-hotfix'
# FTP Config
$FTPUsername = "FTPUSER"
$FTPPassword = "FTPPASSW"

function buildVS
{
    param
    (
        [parameter(Mandatory=$true)]
        [String] $path,

        [parameter(Mandatory=$false)]
        [bool] $nuget = $true,
        
        [parameter(Mandatory=$false)]
        [bool] $clean = $true
    )
    process
    {
        $msBuildExe = 'C:\Program Files (x86)\MSBuild\14.0\Bin\msbuild.exe'

        if ($nuget) {
            Write-Host "Restoring NuGet packages" -foregroundcolor green
            nuget restore "$($path)"
        }

        if ($clean) {
            Write-Host "Cleaning $($path)" -foregroundcolor green
            & "$($msBuildExe)" "$($path)" /t:Clean /m
        }

        Write-Host "Building $($path)" -foregroundcolor green
        & "$($msBuildExe)" "$($path)" /t:Build /m
    }
}

# Build 2 Mal
buildVS -path $SolutionPath -clean $false
buildVS -path $SolutionPath -clean $false

# Hier kannst du einen Tag hinterlegen, zB. kosi, otto, etsy
$Comment = Read-Host -Prompt 'Hinterlassen Sie einen Codekommentar (zB. etsy, kosi, otto)'
$Comment = $Comment -replace '\s','-'

$DestinationObject = String.Empty;
if (!$Comment){
    $DestinationObject = $DestinationPath + ".zip"    
} else {    
    $DestinationObject = $DestinationPath + "-" + $Comment + ".zip"
}

If (!(Test-Path $DestinationPath)){
    New-Item -ItemType Directory -Force -Path $DestinationPath
}

Get-ChildItem -Path $SourcePath -Recurse | Compress-Archive -DestinationPath "$($DestinationObject)"

Set-Clipboard "$($DestinationObject)"

Write-Host 'Der Link zum ZIP befindet sich in der Zwischenablage. Sie koennen ihn von dort ueberall verwenden.'

#FTP Uploader
$LocalFile = $DestinationObject 
$RemoteFile = "ftp://download.marcos-software.com/individual\" + $Username
 
# Create FTP Rquest Object
$FTPRequest = [System.Net.FtpWebRequest]::Create("$RemoteFile")
$FTPRequest = [System.Net.FtpWebRequest]$FTPRequest
$FTPRequest.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
$FTPRequest.Credentials = new-object System.Net.NetworkCredential($FTPUsername, $FTPPassword)
$FTPRequest.UseBinary = $true
$FTPRequest.UsePassive = $true
# Read the File for Upload
$FileContent = gc -en byte $LocalFile
$FTPRequest.ContentLength = $FileContent.Length
# Get Stream Request by bytes
$Run = $FTPRequest.GetRequestStream()
$Run.Write($FileContent, 0, $FileContent.Length)
# Cleanup
$Run.Close()
$Run.Dispose()

Write-Host 'Die Datei: ' + $RemoteFile + ' wurde erfolgreich hochgeladen'