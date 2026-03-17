[CmdletBinding()]
param(
    [switch]$DisableSleepOnAc,
    [switch]$DisableHibernateOnAc,
    [Nullable[int]]$AcSleepMinutes,
    [Nullable[int]]$AcHibernateMinutes,
    [switch]$NoSelfElevate
)

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

function Get-ScriptArgumentList {
    $arguments = @(
        "-NoProfile"
        "-ExecutionPolicy"
        "Bypass"
        "-File"
        "`"$PSCommandPath`""
    )

    if ($DisableSleepOnAc) {
        $arguments += "-DisableSleepOnAc"
    }

    if ($DisableHibernateOnAc) {
        $arguments += "-DisableHibernateOnAc"
    }

    if ($AcSleepMinutes -ne $null) {
        $arguments += @("-AcSleepMinutes", $AcSleepMinutes.ToString())
    }

    if ($AcHibernateMinutes -ne $null) {
        $arguments += @("-AcHibernateMinutes", $AcHibernateMinutes.ToString())
    }

    $arguments += "-NoSelfElevate"
    return $arguments
}

if ($DisableSleepOnAc -and $AcSleepMinutes -ne $null) {
    throw "Use either -DisableSleepOnAc or -AcSleepMinutes, not both."
}

if ($DisableHibernateOnAc -and $AcHibernateMinutes -ne $null) {
    throw "Use either -DisableHibernateOnAc or -AcHibernateMinutes, not both."
}

if ($DisableSleepOnAc) {
    $AcSleepMinutes = 0
}

if ($DisableHibernateOnAc) {
    $AcHibernateMinutes = 0
}

if (-not $NoSelfElevate -and -not (Test-Administrator)) {
    Write-Section "Requesting elevation"
    Write-Host "Relaunching sleep policy update in an elevated PowerShell so the power plan can be updated without extra prompts."
    Start-Process powershell -Verb RunAs -ArgumentList (Get-ScriptArgumentList)
    exit
}

Write-Section "Updating active power scheme"

if ($AcSleepMinutes -ne $null) {
    Write-Host "Setting AC sleep timeout to $AcSleepMinutes minute(s)"
    powercfg /change standby-timeout-ac $AcSleepMinutes | Out-Null
}

if ($AcHibernateMinutes -ne $null) {
    Write-Host "Setting AC hibernate timeout to $AcHibernateMinutes minute(s)"
    powercfg /change hibernate-timeout-ac $AcHibernateMinutes | Out-Null
}

Write-Section "Current AC sleep settings"
powercfg /query SCHEME_CURRENT SUB_SLEEP STANDBYIDLE
powercfg /query SCHEME_CURRENT SUB_SLEEP HIBERNATEIDLE
