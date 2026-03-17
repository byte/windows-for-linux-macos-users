#!/usr/bin/env bash

export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less -FRX"

alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias grep='grep --color=auto'

alias c='clear'
alias open='explorer.exe .'

openpwd() {
  explorer.exe "$(wslpath -w "$PWD")"
}

pbcopy() {
  clip.exe
}

pbpaste() {
  powershell.exe -NoProfile -Command Get-Clipboard | tr -d '\r'
}

if command -v fd >/dev/null 2>&1; then
  alias find='fd'
fi

