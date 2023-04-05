oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\gmay.omp.json" | Invoke-Expression

Import-Module posh-git
Import-Module -Name Terminal-Icons
Import-Module ZLocation
Import-Module PSFzf

# PSFzf has undocumented option to use fd executable for
# file and directory searching. This enables that option.
Set-PsFzfOption -EnableFd:$true

# Custom function to SetLocation, because PSFzf uses
# Get-ChildItem which doesn't use fd and doesn't use
# ignore files. Invoke-FuzzySetLocation is defined here
# https://github.com/kelleyma49/PSFzf/blob/b97263a30addd9a2c84a8603382c92e4e6de0eeb/PSFzf.Functions.ps1#L142
#
# This implementation is for setting FileSystem location
# and implementation uses parts of
# https://github.com/kelleyma49/PSFzf/blob/b97263a30addd9a2c84a8603382c92e4e6de0eeb/PSFzf.Base.ps1#L20
# https://github.com/kelleyma49/PSFzf/blob/b97263a30addd9a2c84a8603382c92e4e6de0eeb/PSFzf.Base.ps1#L35
function Invoke-FuzzySetLocation2() {
  param($Directory = $null)

  if ($null -eq $Directory) {
    $Directory = $PWD.Path
  }

  $result = $null

  try {

    # Color output from fd to fzf if running in Windows Terminal
    $script:RunningInWindowsTerminal = [bool]($env:WT_Session)
    if ($script:RunningInWindowsTerminal) {
      $script:DefaultFileSystemFdCmd = "fd.exe --color always . {0}"
    }
    else {
      $script:DefaultFileSystemFdCmd = "fd.exe . {0}"
    }

    # Wrap $Directory in quotes if there is space (to be passed in fd)
    if ($Directory.Contains(' ')) {
      $strDir = """$Directory"""
    }
    else {
      $strDir = $Directory
    }

    # Call fd to get directory list and pass to fzf
    Invoke-Expression (($script:DefaultFileSystemFdCmd -f '--type directory {0} --max-depth 1') -f $strDir) | Invoke-Fzf | ForEach-Object { $result = $_ }
  }
  catch {

  }

  if ($null -ne $result) {
    Set-Location $result
  }
}

# Show tips about newly added commands
function Get-Tips {

  $tips = @(
    [pscustomobject]@{
      Command     = 'ALT+C'
      Description = 'navigate to deep subdirectory'
    },
    [pscustomobject]@{
        Command     = 'fcd'
        Description = 'navigate to subdirectory'
    },
    [pscustomobject]@{
        Command     = 'fd'
        Description = 'find https://github.com/sharkdp/fd#how-to-use'
    },
    [pscustomobject]@{
      Command     = 'fe'
      Description = 'fuzzy edit file'
    },
    [pscustomobject]@{
      Command     = 'fh'
      Description = 'fuzzy invoke command from history'
    },
    [pscustomobject]@{
      Command     = 'fkill'
      Description = 'fuzzy stop process'
    },
    [pscustomobject]@{
        Command     = 'fz'
        Description = 'ZLocation through fzf'
    },
    [pscustomobject]@{
        Command     = 'gfu'
        Description = 'git fetch upstream'
    },
    [pscustomobject]@{
        Command     = 'grep'
        Description = 'Launches grep with --color=auto'
    },
    [pscustomobject]@{
        Command     = 'l'
        Description = 'Launches ls with -lah (Human Readable)'
    },
    [pscustomobject]@{
        Command     = 'mkdir'
        Description = 'Launches mkdir with -p'
    },
    [pscustomobject]@{
        Command     = 'np'
        Description = 'Notepad++'
    },
    [pscustomobject]@{
        Command     = 'rg'
        Description = 'find in files https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md'
    },
    [pscustomobject]@{
        Command     = 'z'
        Description = 'ZLocation'
    }
  )

  Write-Output $tips | Format-Table
}


# Define aliases
New-Alias -Scope Global -Name fcd -Value Invoke-FuzzySetLocation2 -ErrorAction Ignore
New-Alias -Scope Global -Name fe -Value Invoke-FuzzyEdit -ErrorAction Ignore
New-Alias -Scope Global -Name fh -Value Invoke-FuzzyHistory -ErrorAction Ignore
New-Alias -Scope Global -Name fkill -Value Invoke-FuzzyKillProcess -ErrorAction Ignore
New-Alias -Scope Global -Name fz -Value Invoke-FuzzyZLocation -ErrorAction Ignore
New-Alias -Scope Global -Name np -Value "C:\Program Files\Notepad++\notepad++.exe" -ErrorAction Ignore
New-Alias -Scope Global -Name grep -Value "grep --color=auto" -ErrorAction Ignore
New-Alias -Scope Global -Name l -Value "ls -lah" -ErrorAction Ignore
New-Alias -Scope Global -Name mkdir -Value "mkdir -p" -ErrorAction Ignore

# Add SSH to agent
$computerName = $env:COMPUTERNAME
if ($computerName -eq 'SaigkillsDesk') {
    ssh-add.exe C:\Users\Admin\.ssh\id_ed25519_home
}
else {
    ssh-add.exe C:\Users\Admin\.ssh\id_rsa_op_playox_git
    ssh-add.exe C:\Users\Admin\.ssh\id_ed25519_home
}
# SIG # Begin signature block
# MIIFpAYJKoZIhvcNAQcCoIIFlTCCBZECAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCA8f3OgHIU0R0Pr
# dx0pvKchuT6Cb+zHrSWOI8PB/Cfj5qCCAx0wggMZMIICAaADAgECAhBMVe3+g1ln
# mk5pJ2K6vjPnMA0GCSqGSIb3DQEBBQUAMBcxFTATBgNVBAMMDFNhc2NoYSBNYW5u
# czAeFw0yMzAzMjMxNTI3MTdaFw0yNDAzMjMxNTQ3MTdaMBcxFTATBgNVBAMMDFNh
# c2NoYSBNYW5uczCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAO5uruQl
# UPMUTH3luTbR//aXpN8MTmQUPQxErMp5aB6lRgCz/PPAFEv6WOHgyr/EQXSSwgzL
# xDM+Ub2/WdXHDOFOffm4Evll9UpG8UAvOxhBHLY4KiurJHjRxMLFuKIG2vE+x5k2
# OJB8Uj1IazQiQdkbLO2ROYMUWWGrOL1B/nAUtFgvgGNBtWaRmLr3a3UmkitzXa9l
# DzOCMw/no5Vxpfp/xgpp+F4CmHfd4iO7q4bj78VV4Kt8f1BpQXDorBYnSh8BqYTD
# tNc1oZV4nQR1YIrNaJouHzlf4OhAOhVyT6NCHlWcVSIYAEerl49GUhEjVAhsIkox
# DOTkLob357KhqZUCAwEAAaNhMF8wDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoG
# CCsGAQUFBwMDMBkGA1UdEQQSMBCCDnNhc2NoYW1hbm5zLmRlMB0GA1UdDgQWBBTT
# TErnCoQYNkEmD6rqAvV3hkCDWzANBgkqhkiG9w0BAQUFAAOCAQEAGOiCzA01xdHP
# IGQWX3KjJdRuDv0JXibMBzyHhZWhvzz/dsRteyzGUd0pwb6on365nw35SAkTBg9a
# XFlgUqulMtv7ctrE910qj+4NxNJBEw9vNrVt2wT1NJqnOPust4dhpHcKSMctFQiz
# u/klg/93kvR3/xyJfEU1iYW222VSRGbFxpaaaYWfzGBOVWS/lDlUlzoS9UDaV3bd
# jHW8a/9w8wm5u7UJbb4KtIKFsORZSjNjGyU8/W2KYTawDIVu0EVbGI42ngcMbkgn
# claJmu/qnPzPJ+zf5qFO1Pk+CDmn6UOrDHKHyX23tTVfmALbe5AXhkc0Lt8voQn+
# 3kgjI4mP/jGCAd0wggHZAgEBMCswFzEVMBMGA1UEAwwMU2FzY2hhIE1hbm5zAhBM
# Ve3+g1lnmk5pJ2K6vjPnMA0GCWCGSAFlAwQCAQUAoIGEMBgGCisGAQQBgjcCAQwx
# CjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGC
# NwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIBJDC00ZWyddG1gQ
# fZXhzZIShFoOF9APXHe8M+ohEvb2MA0GCSqGSIb3DQEBAQUABIIBADfozqtWbUMi
# O6Cus8BEMJ5Z8ceNxjKSMx2rpZgV2IGx75zj9jVZAzaDV8dJx2yQo4RJnbs32fmz
# UVkEVLMO3umVLWIHFmyut6xuE4fkkkJL4/SF49NKfxq8V1PRDJlrgH4qySLcBeLP
# JiJkLKLSY5SGm0JIQ6iKxw6X7RHyjOZcd9yFvB8HHFvtMe0h9y/oVGVVJ+UE77Fm
# S2R8JTjqM75iO0IHrw2CJ+mOuDpcbSEw2+D2fYyUw/UMZdr4w5gRAQ+TnHT3Xftb
# Z/TjQqFAPNdtlc6RA0kSED9iX6He+j2Lx8OA/JLuUDyaw2yVlTRlD8kaFa7jmj3U
# EFwYLjAoiVA=
# SIG # End signature block
