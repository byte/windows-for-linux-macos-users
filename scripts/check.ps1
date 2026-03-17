[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

function Get-RegistryValueOrDefault {
    param(
        [string]$Path,
        [string]$Name,
        $Default = $null
    )

    try {
        return (Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop).$Name
    }
    catch {
        return $Default
    }
}

function Test-Command {
    param([string]$Name)
    return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Get-WindowsCapabilityState {
    param([string]$Pattern)

    try {
        $capability = Get-WindowsCapability -Online | Where-Object { $_.Name -like $Pattern } | Select-Object -First 1
        if ($null -eq $capability) {
            return "Missing"
        }

        return $capability.State
    }
    catch {
        return "Unknown"
    }
}

function Get-WslDistroList {
    $output = & wsl.exe --list --quiet 2>$null
    if ($LASTEXITCODE -ne 0) {
        return @()
    }

    return $output |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_ }
}

$rows = @(
    [PSCustomObject]@{
        Setting = "winget"
        Value = if (Test-Command "winget") { (& winget --version) } else { "Missing" }
    }
    [PSCustomObject]@{
        Setting = "PowerShell 7"
        Value = if (Test-Path "$env:ProgramFiles\PowerShell\7\pwsh.exe") { "Installed" } else { "Missing" }
    }
    [PSCustomObject]@{
        Setting = "Windows Terminal"
        Value = if (Test-Path "$env:LOCALAPPDATA\Microsoft\WindowsApps\wt.exe") { "Installed" } else { "Missing" }
    }
    [PSCustomObject]@{
        Setting = "WSL distros"
        Value = (($distros = Get-WslDistroList) -join ", ")
    }
    [PSCustomObject]@{
        Setting = "Hide file extensions"
        Value = Get-RegistryValueOrDefault -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Default "Unknown"
    }
    [PSCustomObject]@{
        Setting = "Show hidden files"
        Value = Get-RegistryValueOrDefault -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Default "Unknown"
    }
    [PSCustomObject]@{
        Setting = "Show protected OS files"
        Value = Get-RegistryValueOrDefault -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSuperHidden" -Default "Unknown"
    }
    [PSCustomObject]@{
        Setting = "Long paths"
        Value = Get-RegistryValueOrDefault -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Default "Unknown"
    }
    [PSCustomObject]@{
        Setting = "Developer Mode"
        Value = Get-RegistryValueOrDefault -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Default "Unknown"
    }
    [PSCustomObject]@{
        Setting = "OpenSSH client"
        Value = Get-WindowsCapabilityState -Pattern "OpenSSH.Client*"
    }
)

$rows | Format-Table -AutoSize

Write-Host ""
Write-Host "Interpretation:"
Write-Host "  HideFileExt = 0 is preferred"
Write-Host "  Hidden = 1 is preferred"
Write-Host "  ShowSuperHidden = 1 is preferred"
Write-Host "  LongPathsEnabled = 1 is preferred"
Write-Host "  AllowDevelopmentWithoutDevLicense = 1 is preferred"

