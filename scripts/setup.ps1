[CmdletBinding()]
param(
    [string]$Distro = "Ubuntu",
    [switch]$InstallOptionalPackages,
    [switch]$SkipWsl,
    [switch]$ForceInstall,
    [switch]$SkipSleepPolicy
)

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

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

function Get-ScriptArgumentList {
    $arguments = @(
        "-NoProfile"
        "-ExecutionPolicy"
        "Bypass"
        "-File"
        "`"$PSCommandPath`""
    )

    if ($Distro -ne "Ubuntu") {
        $arguments += @("-Distro", "`"$Distro`"")
    }

    if ($InstallOptionalPackages) {
        $arguments += "-InstallOptionalPackages"
    }

    if ($SkipWsl) {
        $arguments += "-SkipWsl"
    }

    if ($ForceInstall) {
        $arguments += "-ForceInstall"
    }

    if ($SkipSleepPolicy) {
        $arguments += "-SkipSleepPolicy"
    }

    return $arguments
}

if (-not (Test-Administrator)) {
    Write-Section "Requesting elevation"
    Write-Host "Relaunching setup in an elevated PowerShell so the full workstation bootstrap can run with a single UAC prompt."
    Start-Process powershell -Verb RunAs -ArgumentList (Get-ScriptArgumentList)
    exit
}

Write-Section "Auditing current state"
& (Join-Path $scriptRoot "check.ps1")

Write-Section "Bootstrapping host packages and WSL"
$bootstrapArgs = @(
    "-NoProfile"
    "-ExecutionPolicy"
    "Bypass"
    "-File"
    "`"$(Join-Path $scriptRoot 'bootstrap.ps1')`""
    "-NoSelfElevate"
    "-Distro"
    "`"$Distro`""
)

if ($InstallOptionalPackages) {
    $bootstrapArgs += "-InstallOptionalPackages"
}

if ($SkipWsl) {
    $bootstrapArgs += "-SkipWsl"
}

if ($ForceInstall) {
    $bootstrapArgs += "-ForceInstall"
}

Start-Process powershell -Wait -ArgumentList $bootstrapArgs

Write-Section "Applying Windows settings"
Start-Process powershell -Wait -ArgumentList @(
    "-NoProfile"
    "-ExecutionPolicy"
    "Bypass"
    "-File"
    "`"$(Join-Path $scriptRoot 'apply.ps1')`""
    "-NoSelfElevate"
)

if (-not $SkipSleepPolicy) {
    Write-Section "Updating power policy"
    Start-Process powershell -Wait -ArgumentList @(
        "-NoProfile"
        "-ExecutionPolicy"
        "Bypass"
        "-File"
        "`"$(Join-Path $scriptRoot 'set-sleep-policy.ps1')`""
        "-NoSelfElevate"
        "-DisableSleepOnAc"
        "-DisableHibernateOnAc"
    )
}

Write-Section "Setup complete"
Write-Host "If WSL was installed or Windows features changed, a reboot may still be required."

