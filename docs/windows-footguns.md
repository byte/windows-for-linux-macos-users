# Windows Footguns

These are the handful of things that still surprise Unix-native developers.

## Path length

Some tools still trip over legacy path-length behavior. Enable long paths on the host.

## Case sensitivity

Windows is usually case-insensitive. Some repos and toolchains assume case-sensitive behavior. Enable directory-level case sensitivity only where needed.

## Line endings

Pick a Git strategy and be explicit. Blindly accepting defaults is how you end up with noisy diffs.

## Two Git worlds

Git for Windows and Git inside WSL can both work, but mixing them on the same repo carelessly causes confusion. Prefer Git inside WSL for repos that live in WSL.

## Filesystem boundary

Crossing back and forth between Linux files and Windows files is convenient, but it is not free. Expect different performance, permissions, and watch behavior.

## Terminal settings

Windows Terminal is excellent, but it should be treated as user config. A repo can provide starter settings, not a surprise overwrite.

