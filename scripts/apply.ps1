[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

function Write-Section {
    param([string]$Message)
    Write-Host ""
    Write-Host "== $Message ==" -ForegroundColor Cyan
}

function Test-Administrator {
    $currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Set-RegistryDword {
    param(
        [string]$Path,
        [string]$Name,
        [int]$Value
    )

    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }

    $current = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
    if ($null -eq $current -or $current.$Name -ne $Value) {
        New-ItemProperty -Path $Path -Name $Name -PropertyType DWord -Value $Value -Force | Out-Null
        Write-Host "Set $Path\$Name = $Value"
    }
    else {
        Write-Host "$Path\$Name already set"
    }
}

$isAdmin = Test-Administrator

Write-Section "Applying current-user Explorer settings"
Set-RegistryDword -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0
Set-RegistryDword -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1
Set-RegistryDword -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSuperHidden" -Value 1

if ($isAdmin) {
    Write-Section "Applying machine-wide developer settings"
    Set-RegistryDword -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1
    Set-RegistryDword -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Value 1

    Write-Section "Ensuring OpenSSH client is available"
    $openSshClient = Get-WindowsCapability -Online | Where-Object { $_.Name -like "OpenSSH.Client*" } | Select-Object -First 1
    if ($null -ne $openSshClient -and $openSshClient.State -ne "Installed") {
        Add-WindowsCapability -Online -Name $openSshClient.Name | Out-Null
        Write-Host "Installed OpenSSH client"
    }
    else {
        Write-Host "OpenSSH client already installed"
    }
}
else {
    Write-Warning "Run this script in an elevated PowerShell session to enable long paths, developer mode, and OpenSSH client."
}

Write-Section "Apply complete"
Write-Host "Explorer may need to be restarted or you may need to sign out and back in for some settings to appear."

