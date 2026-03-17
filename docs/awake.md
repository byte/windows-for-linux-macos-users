# Staying Awake During Long Tasks

There are two different problems that people often mix together:

- "Do not ever sleep while plugged in"
- "Do not sleep while this one long-running command is active"

This repo supports both.

## Recommended default

For development machines, a good default is:

- never sleep on AC power
- keep the display timeout separate so the screen can still turn off if you want

Use:

```powershell
.\scripts\set-sleep-policy.ps1 -DisableSleepOnAc
```

## Command-scoped awake mode

If you only want to prevent sleep while a command is running, use:

```powershell
.\scripts\invoke-awake.ps1 codex
.\scripts\invoke-awake.ps1 claude
```

This does not permanently alter the power plan. It uses the Windows execution state API for the lifetime of the wrapped command.

## Notes

- The wrapper prevents system sleep.
- By default it does not force the display to stay on.
- If you need the screen to stay awake too, use `-KeepDisplayOn`.

