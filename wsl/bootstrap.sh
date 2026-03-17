#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
packages_file="$repo_root/wsl/packages.txt"
shell_source="$HOME/.config/windows-for-linux-macos-users/shell/common.sh"

if ! command -v apt-get >/dev/null 2>&1; then
  echo "This bootstrap currently supports Debian/Ubuntu-style distros." >&2
  exit 1
fi

mapfile -t packages < <(grep -v '^\s*#' "$packages_file" | sed '/^\s*$/d')

echo "Installing WSL packages..."
sudo apt-get update
sudo apt-get install -y "${packages[@]}"

mkdir -p "$(dirname "$shell_source")"
install -m 0644 "$repo_root/wsl/dotfiles/shell/common.sh" "$shell_source"

for rc_file in "$HOME/.bashrc" "$HOME/.zshrc"; do
  touch "$rc_file"
  if ! grep -Fq "$shell_source" "$rc_file"; then
    {
      echo
      echo "# windows-for-linux-macos-users"
      echo "[ -f \"$shell_source\" ] && source \"$shell_source\""
    } >> "$rc_file"
  fi
done

mkdir -p "$HOME/.local/bin"

if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
  ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
fi

cat <<'EOF'

WSL bootstrap complete.

Next ideas:
- Set your default shell to zsh if that is your preference
- Copy or merge your personal Git config
- Install language runtimes and toolchains specific to your work
EOF

