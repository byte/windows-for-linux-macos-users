[CmdletBinding()]
param(
    [switch]$KeepDisplayOn,
    [Parameter(Mandatory = $true, Position = 0, ValueFromRemainingArguments = $true)]
    [string[]]$Command
)

$ErrorActionPreference = "Stop"

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public static class PowerState
{
    [DllImport("kernel32.dll")]
    public static extern uint SetThreadExecutionState(uint esFlags);
}
"@

$ES_CONTINUOUS = [UInt32]::Parse("2147483648")
$ES_SYSTEM_REQUIRED = [UInt32]1
$ES_DISPLAY_REQUIRED = [UInt32]2

$flags = $ES_CONTINUOUS -bor $ES_SYSTEM_REQUIRED
if ($KeepDisplayOn) {
    $flags = $flags -bor $ES_DISPLAY_REQUIRED
}

$commandName = $Command[0]
$commandArgs = @()
if ($Command.Count -gt 1) {
    $commandArgs = $Command[1..($Command.Count - 1)]
}

Write-Host "Keeping the system awake while '$commandName' is running..."
[void][PowerState]::SetThreadExecutionState($flags)

try {
    & $commandName @commandArgs
    $exitCode = $LASTEXITCODE
}
finally {
    [void][PowerState]::SetThreadExecutionState($ES_CONTINUOUS)
}

if ($null -ne $exitCode) {
    exit $exitCode
}
