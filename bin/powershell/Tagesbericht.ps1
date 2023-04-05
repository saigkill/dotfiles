# Script zum erstellen von Tagesberichten
# 2022 by Sascha Manns <s.manns@marcossoftware.com>"

# User und Companyvariablen
$user = "Sascha Manns"
$email = "s.manns@marcossoftware.com"
$smtp_server = "smtp.office365.com"
$path_to_mailPW = "C:\Users\Sascha\OneDrive\Keys\ArbeitMailPW.txt"
$touser1 = "Levent Yaman"
$touser1_email = "l.yaman@marcossoftware.com"
$touser2 = "Mick Heisterbach"
$touser2_email ="m.heisterbach@marcossoftware.com"
$company = "marcos software"
$vim = "C:\Program Files\Vim\vim82\vim.exe"
$mode = "Clipboard" # Clipboard or Mail

# Generiere Credential Object gefunden auf https://www.windowspro.de/script/send-mailmessage-e-mails-versenden-powershell
# $pw = Get-Content -Path $path_to_mailPW | ConvertTo-SecureString
# $smtp_password = New-Object System.Management.Automation.PSCredential "MailUser", $pw

# Datums und Zeitvariablen
$date = Get-Date -Format "dd/MM/yyyy".ToString()
$year = Get-Date -format "yyyy".ToString()
$month = Get-Date -format "MM".ToString()
$day = Get-Date -format "dd".ToString()
#$weekOfYear = Get-Date -UFormat %V

# Benutzerdirectory und Pfad zu den Wochenberichten
$userdir = $env:USERPROFILE
$docpath = $userdir + "/Workreports/$year/$month"

# Check ob Pfad existiert
if (Test-Path -Path $docpath){
    # Do Nothing
} else {
    New-Item -Path $docpath -ItemType directory
}

# Template für neue Wochenberichte
$template = @"
$company work report für $user vom $date

[IN ARBEIT]

[ABGESCHLOSSEN]

[NEXT]
* Unicorn Feature für Wayfair: Keine ASN bei Logistikern von Wayfair.
* Bibliothek erstellen, die den Lizenzserver der Apps implementiert.
* Darauf basierend eine App erstellen, die den gesamten Lizenz und Telemetriebereich abdecken kann.
* Dokumentation für sämtliche Apps, so das sie jeder installieren und einrichten kann.

[PENDING]
* Call mit Wayfair und Pilotkunden (Vorstellung und Test der Inventory-App). Genaues Datum noch keines festgelegt.

Gesamtzeit: $time
"@

# Speichere Datei und öffne vim
$workreportFile = $docpath + "/" + $day + ".txt"

if (Test-Path -Path $workreportFile) {
    Start-Process -FilePath $vim -ArgumentList $workreportFile -NoNewWindow
} else {
    Set-Content -Path $workreportFile -Value $template -Encoding UTF8
    Start-Process -FilePath $vim -ArgumentList $workreportFile -NoNewWindow
}

#if ($mode == "Clipboard") {
    #$content = [IO.File]::ReadAllText($workreportFile)
    #Set-Clipboard -Value $content
#} else {
    ## Sende Email an obige Empfänger
    #Send-MailMessage -Credential $smtp_password -From "$user <$email>" -To "$touser1 <$touser1_email>", "$touser2 <$touser2_email>" -Subject "[Tagesbericht Sascha Manns] $filesuffix $day/$month/$year" -Body "Der Tagesbericht $filesuffix" -Attachments $workreportFile -Priority Medium -DeliveryNotificationOption OnSuccess, OnFailure -SmtpServer $smtp_server -encoding ([System.Text.Encoding]::UTF8)
#}

