#!/usr/bin/env bash
# Start a fresh Claude Code session with a prepared session prompt as its first message.
#
# Usage:  tools/session/start-session.sh <id>        e.g. 10b, 11
#         tools/session/start-session.sh --list
#         tools/session/start-session.sh <id> --print   (show the prompt, do not start)
#         tools/session/start-session.sh <id> --new-window  (open the session in a new
#                                    terminal window; usable from inside Claude Code)
#
# Reads production/session-prompts/session-<id>-*.md and sends the content of its
# FIRST ``` code block. Always starts from the project root, so the project's
# hooks, deny rules and ask-first mode load (CLAUDE.md).
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$root"
dir="production/session-prompts"

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <id> [--print] | --list" >&2
  exit 2
fi

if [[ "$1" == "--list" ]]; then
  ls "$dir" | sed -n 's/^session-\([^-]*\)-\(.*\)\.md$/\1\t\2/p'
  exit 0
fi

shopt -s nullglob
matches=("$dir"/session-"$1"-*.md)
if [[ ${#matches[@]} -ne 1 ]]; then
  echo "error: expected exactly one file for id '$1', found ${#matches[@]}" >&2
  printf '  %s\n' "${matches[@]}" >&2
  exit 1
fi
file="${matches[0]}"

prompt="$(awk '/^```/{n++; next} n==1' "$file")"
if [[ -z "${prompt//[[:space:]]/}" ]]; then
  echo "error: no \`\`\` code block found in $file" >&2
  exit 1
fi

if [[ "${2:-}" == "--print" ]]; then
  printf '%s\n' "$prompt"
  exit 0
fi

if [[ "${2:-}" == "--new-window" ]]; then
  self="$root/tools/session/start-session.sh"
  if command -v ptyxis >/dev/null; then
    term=(ptyxis --new-window --)
  elif command -v gnome-terminal >/dev/null; then
    term=(gnome-terminal --)
  elif command -v x-terminal-emulator >/dev/null; then
    term=(x-terminal-emulator -e)
  else
    echo "error: no terminal emulator found (ptyxis, gnome-terminal, x-terminal-emulator)" >&2
    exit 1
  fi
  # Drop the calling Claude Code session's variables so the new window starts a
  # top-level session, not a child of this one.
  clean=(env)
  while IFS='=' read -r k _; do
    [[ "$k" == CLAUDECODE || "$k" == CLAUDE_* ]] && clean+=(-u "$k")
  done < <(env)
  setsid "${clean[@]}" "${term[@]}" bash -lc "cd '$root' && '$self' '$1'; exec bash" >/dev/null 2>&1 < /dev/null &
  echo "Opened a new terminal window for: $file" >&2
  exit 0
fi

echo "Starting a new Claude Code session with: $file" >&2
exec claude "$prompt"
