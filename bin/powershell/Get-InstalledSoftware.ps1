# More on: https://cipriandroc.wordpress.com/2020/08/30/get-installedsoftware-ps1/
[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string[]]$software,
    [Parameter(Mandatory = $false)]
    [string]$ExportLocation,
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string[]]$ComputerName,
    [ValidateSet('c:\temp', 'c:\data\output', '\\fileserver\installations\cdroc\data\output')]
    [string]$PredefinedLocation
)
#filename used for exporting at the end of the script
$filename = 'SoftwareReport'
#region Functions
function Export-Results {
    Param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $results,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        $filename,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$ExportLocation
    )
    $date = (get-date).tostring('MM.dd') 
    $generatefilename = $date + '_' + $filename + '.csv'
    if (Test-Path $ExportLocation) {
        if (test-path $ExportLocation\$generatefilename) { Write-Output "Appending information: $exportlocation to file $generatefilename" }
        else { Write-Output "Exported file to $exportlocation as $generatefilename" }
        $results | Export-Csv -Path $ExportLocation\$generatefilename -Append -NoTypeInformation
    }
    else {
        Write-Warning "Cannot export information."
        Write-Warning "$exportlocation is not a valid location."
    }
}
function Get-Results {
    Param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string[]]$software
    )

    $location1 = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, PSChildName, @{Name = "InstallDate"; Expression = { ([datetime]::ParseExact($_.InstallDate, 'yyyyMMdd', $null)).toshortdatestring() } }, @{n = "method"; e = { "registry" } }
    $location2 = Get-ItemProperty HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, PSChildName, @{Name = "InstallDate"; Expression = { ([datetime]::ParseExact($_.InstallDate, 'yyyyMMdd', $null)).toshortdatestring() } }, @{n = "method"; e = { "registry" } }
    $location3 = Get-Package *

    foreach ($soft in $software) {    
        $outputProps = [ordered]@{
            "ComputerName"    = $env:COMPUTERNAME;
            "method"          = $null;
            "searched"        = $soft;
            "DisplayName"     = $null;
            "DisplayVersion"  = $null;
            "ApplicationGUID" = $null;
            "InstallDate"     = $null;
        }

        $results = @()
        $results += $location1 | Where-Object { ($_.displayname -like '*' + "$soft" + '*') } 
        $results += $location2 | Where-Object { ($_.displayname -like '*' + "$soft" + '*') } 
        $results += $location3 | Where-Object { ($_.Name -like '*' + "$soft" + '*') } | Select-Object @{n = "method"; e = { "get-package" } }, @{n = 'DisplayName'; e = { $_.Name } }, @{n = 'DisplayVersion'; e = { $_.Version } }, @{n = "PSChildName"; e = { $_.TagId } }, @{Name = "InstallDate"; Expression = { "N/A" } }
       
        foreach ($result in $results) {
            $foundOutputProps = New-Object psobject -Property $outputProps
            $foundOutputProps.method = $result.method
            $foundOutputProps.DisplayName = $result.DisplayName
            $foundOutputProps.DisplayVersion = $result.DisplayVersion
            $foundOutputProps.ApplicationGUID = $result.PSChildName
            $foundOutputProps.InstallDate = $result.InstallDate
            $foundOutputProps
        }
        if (!$results) {
            $noOutputProps = New-Object psobject -Property $outputProps
            $noOutputProps.method = "N/A"
            $noOutputProps.DisplayName = "Not Found"
            $noOutputProps.DisplayVersion = "N/A"
            $noOutputProps.ApplicationGUID = "N/A"
            $noOutputProps.InstallDate = "N/A"
            $noOutputProps
        }
        remove-Variable results
    }

}
#endregion Functions

#region RemoteComputers Code
if ($ComputerName) {
    $results = @()
    $results += Invoke-Command -ComputerName $ComputerName -ScriptBlock ${function:Get-Results} -ArgumentList (, $software) -HideComputerName -ErrorVariable remoteerrors -ErrorAction SilentlyContinue | Select-Object * -exclude RunspaceID, PSComputerName, PSShowComputerName
    $remoteerrors = $remoteerrors | Select-Object @{ n = 'ComputerName' ; e = { $PSItem.TargetObject } },
    @{ n = 'method'; e = { 'N/A' } },
    @{ n = 'searched'; e = { 'N/A' } },
    @{ n = 'DisplayName' ; e = { 'Cannot connect to the host' } },
    @{ n = 'DisplayVersion'; e = { 'N/A' } },
    @{ n = 'ApplicationGUID'; e = { 'N/A' } },
    @{ n = 'InstallDate'; e = { 'N/A' } }
    $results += $remoteerrors
}
#endregion RemoteComputersCode
#region LocalComputer Code
else {
    $results = Get-Results -software $software
}
#endregion LocalComputer Code

#region EndArea
$results | Format-Table -AutoSize

if ($ExportLocation -or $PredefinedLocation) {
    if ($PredefinedLocation) { $ExportLocation = $PredefinedLocation }
    Export-Results -results $results -ExportLocation $ExportLocation -filename $filename
}
#endregion EndArea




#region TODO's , comments
#PRIO#
##!!!output full object without format-table, just do a display version to the command output
#!! GUID for get-package results
#FIX APPLICATION GUID, iT EXTRACTS THE FOLDER NAME, MOST HAVE GUID AS FOLDER NAME BUT ALOT HAVE THE ACTUAL APPLICATION NAME IN THE FOLDERNAME
#add parameter toggle called Extended Properties that reveals more information like app GUID, install location
#Optional: add column with scan date

#DONE#
#DONE!! Fix CSV columsn PSComputerName	PSShowComputerName .. remove
#DONE#after revamp : output remote command errors to table , could not connect, bla bla
#DONECORRECT-ERR: blank space in method if search software is bad , needs N/A
#DONE!!!!!!!!TRY TO RUN INVOKE COMMAND WITH THE COMPUTERNAME STRING DIRECTLY SO IT PROCESS ALL IN PARALLEL!!!!
#DONECORRECT-ERR: N/A input bad soft for no computers results in computername instead of localhost like the others, or viceversa
#DONEcheck for connection error and display connection failed properties -like 'DisplayName' ConnectionError
#DONE  change export location to paramter toggle that has predefined locations and have separate parameter for export location where you set it yourself
#DONE  !!INCORPORATE GET-PACKAGE | have it run alongside the registry method, have them output alongside and create new column named method or provider: getpackage, registry
#DONE - add multiple software scans
#DONE - Splat the select-object properties in a $var
#!!!!!!!!MOVE THE SOFTWARE WHERE -eq FUNCTION OUTSIDE THE SOFT BLOCK SO IT DOES A SINGLE SCAN THEN STORES IT IN A VARIABLE AND THE FOREACH SOFT RUNS ON THE VARIABLE ITSELF!!!!!!!!!!!!

<#
    [string]$placeholder,
    [ValidateNotNullOrEmpty()]
    [ServerType]$ServerType

$placeholder =  enum ServerType {
        Web
        SQL
        DoomainController
        }


#>
#endregion TODO's , comments
#depreciated
#    $errors = $error | ForEach-Object { [regex]::matches($_, '(?<=\[)(.*?)(?=\])').Value }
<#
    foreach ($err in $errors) {
        $CNError = [PSCustomObject]@{
            "ComputerName"    = $err.ToUpper();
            "method"          = "N/A";
            "searched"        = "N/A";
            "DisplayName"     = "Could not connecto to Host";
            "DisplayVersion"  = "N/A";
            "ApplicationGUID" = "N/A";
            "InstallDate"     = "N/A";
        }    
        $results += $CNError
#>