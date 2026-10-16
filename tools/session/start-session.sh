#!/usr/bin/env bash
# Start a fresh Claude Code session with a prepared session prompt as its first message.
#
# Usage:  tools/session/start-session.sh <id>        e.g. 10b, 11
#         tools/session/start-session.sh --list
#         tools/session/start-session.sh <id> --print   (show the prompt, do not start)
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

echo "Starting a new Claude Code session with: $file" >&2
exec claude "$prompt"
