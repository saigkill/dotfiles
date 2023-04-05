# Script zum erstellen von Wochenberichten
# 2022 by Sascha Manns <Sascha.Manns@outlook.de>"

# User und Companyvariablen
$user = "Sascha Manns"
$email = "s.manns@marcossoftware.com"
$smtp_server = "smtp.office365.com"
$smtp_user = "s.manns@marcossoftware.com"
$path_to_mailPW = "C:\Users\Sascha\OneDrive\Keys\ArbeitMailPW.txt"
$touser1 = "Marvin Zimmermann"
$touser1_email = "m.zimmermann@marcossoftware.com"
$touser2 = "Mick Heisterbach"
$touser2_email ="m.heisterbach@marcossoftware.com"
$company = "marcos software"
$vim = "C:\Program Files (x86)\Vim\vim82\vim.exe"

# Generiere Credential Object gefunden auf https://www.windowspro.de/script/send-mailmessage-e-mails-versenden-powershell
$pw = Get-Content -Path $path_to_mailPW | ConvertTo-SecureString
$smtp_password = New-Object System.Management.Automation.PSCredential "MailUser", $pw

# Datums und Zeitvariablen
$date = Get-Date -Format "dd/MM/yyyy".ToString()
$year = Get-Date -format "yyyy".ToString()
$day = Get-Date -format "dddd".ToString()
$weekOfYear = Get-Date -UFormat %V

# Benutzerdirectory und Pfad zu den Wochenberichten
$userdir = $env:USERPROFILE
$docpath = $userdir + "/Workreports/$year"

# Check ob Pfad existiert
if (!Test-Path -Path $docpath){
    New-Item -Path $docpath -ItemType directory
}

if ($day = "Mittwoch") {
    $time = "24"
    $filesuffix = "M"
} else {
    $time = "16 (Gesamt Woche: 40)"
    $filesuffix = "F"
}

# Template für neue Wochenberichte
$template = @"
$company work report für $user ($weekOfYear/$year) vom $date

[ANSTEHEND]

[IN ARBEIT]

[ABGESCHLOSSEN]

[INFOS FEHLEN]

Gesamtzeit: $time
"@

# Speichere Datei und öffne vim
$workreportFile = $docpath + "/" + $weekOfYear + $filesuffix + ".txt"    

if (Test-Path -Path $workreportFile) {
    Start-Process -FilePath $vim -ArgumentList $workreportFile -NoNewWindow
} else {
    Set-Content -Path $workreportFile -Value $template
    Start-Process -FilePath $vim -ArgumentList $workreportFile -NoNewWindow
}

# Sende Email an obige Empfänger
Send-MailMessage -Credential $smtp_password -From "$user <$email>" -To "$touser1 <$touser1_email>", "$touser2 <$touser2_email>" -Subject "[Biwochenbericht Sascha Manns] $filesuffix $weekOfYear/$year" -Body "Der Wochenbericht $filesuffix" -Attachments $workreportFile -Priority Medium -DeliveryNotificationOption OnSuccess, OnFailure -SmtpServer 'smtp.office365.com' -encoding ([System.Text.Encoding]::UTF8)
