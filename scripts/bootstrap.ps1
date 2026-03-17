[CmdletBinding()]
param(
    [string]$Distro = "Ubuntu",
    [switch]$InstallOptionalPackages,
    [switch]$SkipWsl,
    [switch]$ForceInstall
)

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptRoot
$basePackagesPath = Join-Path $repoRoot "winget\base-packages.txt"
$optionalPackagesPath = Join-Path $repoRoot "winget\optional-packages.txt"

function Write-Section {
    param([string]$Message)
    Write-Host ""
    Write-Host "== $Message ==" -ForegroundColor Cyan
}

function Test-Command {
    param([string]$Name)
    return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Get-PackageIds {
    param([string]$Path)

    Get-Content -Path $Path |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_ -and -not $_.StartsWith("#") }
}

function Test-WingetPackageInstalled {
    param([string]$PackageId)

    & winget list --id $PackageId --exact --accept-source-agreements 2>$null | Out-Null
    return $LASTEXITCODE -eq 0
}

function Install-WingetPackageList {
    param(
        [string[]]$PackageIds,
        [switch]$ForceInstall
    )

    foreach ($packageId in $PackageIds) {
        if (-not $ForceInstall -and (Test-WingetPackageInstalled -PackageId $packageId)) {
            Write-Host "Skipping $packageId (already installed)"
            continue
        }

        Write-Host "Installing $packageId"
        & winget install --id $packageId --exact --accept-package-agreements --accept-source-agreements --silent
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "winget reported a non-zero exit code for $packageId"
        }
    }
}

function Get-WslDistros {
    $output = & wsl.exe --list --quiet 2>$null
    if ($LASTEXITCODE -ne 0) {
        return @()
    }

    return $output |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_ }
}

if (-not (Test-Command "winget")) {
    throw "winget is not available. Install App Installer from Microsoft and try again."
}

Write-Section "Installing base Windows packages"
Install-WingetPackageList -PackageIds (Get-PackageIds -Path $basePackagesPath) -ForceInstall:$ForceInstall

if ($InstallOptionalPackages) {
    Write-Section "Installing optional Windows packages"
    Install-WingetPackageList -PackageIds (Get-PackageIds -Path $optionalPackagesPath) -ForceInstall:$ForceInstall
}

if (-not $SkipWsl) {
    Write-Section "Checking WSL"
    $distros = Get-WslDistros

    if ($distros.Count -eq 0) {
        Write-Host "No WSL distro detected. Attempting to install $Distro..."
        & wsl.exe --install -d $Distro
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "WSL install did not complete cleanly. A reboot may be required."
        }
    }
    elseif ($distros -notcontains $Distro) {
        Write-Host "WSL is enabled but distro '$Distro' is not installed. Attempting install..."
        & wsl.exe --install -d $Distro
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Distro install did not complete cleanly. A reboot may be required."
        }
    }
    else {
        Write-Host "WSL distro '$Distro' is already installed."
    }

    Write-Host ""
    Write-Host "Next step inside WSL:"
    Write-Host "  ./wsl/bootstrap.sh"
}

Write-Section "Bootstrap complete"
