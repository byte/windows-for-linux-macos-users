# windows-for-linux-macos-users

An opinionated starter kit for turning a Windows machine into a comfortable workstation for developers who think in Unix.

This repo is for people who are productive on macOS or Linux, but are stuck using Windows at work and want the machine to feel familiar fast.

## Philosophy

- Use Windows for the host layer.
- Use WSL 2 for normal development.
- Keep setup reproducible, scriptable, and easy to review.
- Prefer safe, idempotent changes over login-time magic.

## What this repo does

- Installs a solid baseline of Windows developer tools with `winget`
- Applies a few high-value Windows settings that reduce friction
- Bootstraps a WSL distro with familiar Unix command-line tools
- Documents the Windows-specific footguns that still matter

## Quick start

Open an elevated PowerShell session in this repo and run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\check.ps1
.\scripts\bootstrap.ps1 -InstallOptionalPackages
.\scripts\apply.ps1
```

Then, inside your WSL distro:

```bash
./wsl/bootstrap.sh
```

## Suggested workflow

1. Run [`check.ps1`](/C:/Users/cchar/source/repos/byte/windows-for-linux-macos-users/scripts/check.ps1) to see the current machine state.
2. Run [`bootstrap.ps1`](/C:/Users/cchar/source/repos/byte/windows-for-linux-macos-users/scripts/bootstrap.ps1) to install packages and WSL prerequisites.
3. Run [`apply.ps1`](/C:/Users/cchar/source/repos/byte/windows-for-linux-macos-users/scripts/apply.ps1) to apply the lowest-risk Windows settings.
4. Open your distro and run [`bootstrap.sh`](/C:/Users/cchar/source/repos/byte/windows-for-linux-macos-users/wsl/bootstrap.sh).
5. Customize the package lists and shell snippets for your own taste.

## Repo layout

```text
docs/        Explanations, tradeoffs, and Windows-specific notes
powertoys/   Notes for reproducible PowerToys setup
scripts/     Windows bootstrap, apply, and audit scripts
terminal/    Windows Terminal starter settings
winget/      Package lists for host-side installs
wsl/         Linux-side bootstrap and shell defaults
```

## What belongs where

- Host-side tools: Git for Windows, PowerShell 7, Windows Terminal, PowerToys, OpenSSH, fonts, Explorer settings
- WSL-side tools: language runtimes, compilers, package managers, editor tooling, shell customizations
- Bridge tools: clipboard helpers, `explorer.exe`, path translation, Terminal profiles, editor launchers

The short version is in [`docs/host-vs-wsl.md`](/C:/Users/cchar/source/repos/byte/windows-for-linux-macos-users/docs/host-vs-wsl.md).

## Defaults in this scaffold

Base Windows packages live in [`winget/base-packages.txt`](/C:/Users/cchar/source/repos/byte/windows-for-linux-macos-users/winget/base-packages.txt).

Optional Windows packages live in [`winget/optional-packages.txt`](/C:/Users/cchar/source/repos/byte/windows-for-linux-macos-users/winget/optional-packages.txt).

Base WSL packages live in [`wsl/packages.txt`](/C:/Users/cchar/source/repos/byte/windows-for-linux-macos-users/wsl/packages.txt).

## A few strong opinions

- Do not try to make `cmd.exe` your main shell.
- Do not put Linux repos under `/mnt/c/...` unless you have a specific reason.
- Do not overwrite a user's Windows Terminal settings automatically.
- Do not hide important machine changes behind startup tasks unless the user asked for that behavior.

## Next steps for the repo

- Add a PowerToys Keyboard Manager export path once the format is stable enough
- Add distro-specific WSL bootstraps for Ubuntu and Debian
- Add optional profiles for `pwsh`, Ubuntu, and a "Windows admin" shell in Terminal
- Add CI checks for PowerShell syntax and shell script linting

