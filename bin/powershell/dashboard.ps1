# Script for building a Dashboard in Powershell
# From: https://dev.to/jcoelho/powershell-universal-dashboard-making-interactive-dashboards-9kl?msclkid=1f6c0bcebf1011ec9e0f657e75dcf246
$theme = Get-UDTheme -Name 'Azure'
$refreshRate = 10
$dashboard = New-UDDashboard -Title "DevTo Dashboard" -Theme $theme -Content{

New-UDChart -Title "Disk Space" -Type Doughnut -RefreshInterval $refreshRate -Endpoint {  
            try {
                Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object {$_.DriveType -eq '3'} | Select-Object -First 1 -Property DeviceID,Size,FreeSpace | ForEach-Object {
                    @([PSCustomObject]@{
                        Label = "Used Space"
                        Data = [Math]::Round(($_.Size - $_.FreeSpace) / 1GB, 2);
                    },
                    [PSCustomObject]@{
                        Label = "Free Space"
                        Data = [Math]::Round($_.FreeSpace / 1GB, 2);
                    }) | Out-UDChartData -DataProperty "Data" -LabelProperty "Label" -BackgroundColor @("#80FF6B63","#8028E842") -HoverBackgroundColor @("#80FF6B63","#8028E842") -BorderColor @("#80FF6B63","#8028E842") -HoverBorderColor @("#F2675F","#68e87a")
                }
            }
            catch {
                0 | Out-UDChartData -DataProperty "Data" -LabelProperty "Label"
            }
        }

}

Start-UDDashboard -Dashboard $dashboard -Port 1002 -AutoReload