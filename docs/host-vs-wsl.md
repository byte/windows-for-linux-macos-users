# Host vs WSL

If you are coming from macOS or Linux, the most useful mental model is:

- Windows is the host operating system.
- WSL is your normal development environment.

That split keeps things clean.

## Use Windows for

- GUI apps
- Device drivers
- Corporate VPN, MDM, antivirus, and office tooling
- Windows-native admin tasks
- PowerToys, Terminal, fonts, file associations, Explorer preferences

## Use WSL for

- Shell work
- Git
- Language runtimes
- Build tools
- Package managers
- Editor and CLI workflows

## Bridge carefully

- Open the current Linux folder in Explorer with `explorer.exe .`
- Copy to the Windows clipboard with `clip.exe`
- Read the Windows clipboard from WSL with `powershell.exe -NoProfile -Command Get-Clipboard`
- Translate paths with `wslpath`

## Important rule

Keep active Linux projects in the Linux filesystem inside WSL whenever possible. That is the happy path for performance and file watching.

