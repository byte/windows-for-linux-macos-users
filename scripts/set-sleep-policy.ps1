[CmdletBinding()]
param(
    [switch]$DisableSleepOnAc,
    [switch]$DisableHibernateOnAc,
    [Nullable[int]]$AcSleepMinutes,
    [Nullable[int]]$AcHibernateMinutes
)

$ErrorActionPreference = "Stop"

function Write-Section {
    param([string]$Message)
    Write-Host ""
    Write-Host "== $Message ==" -ForegroundColor Cyan
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

