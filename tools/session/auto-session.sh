#!/usr/bin/env bash
# Run Claude Code sessions back to back, each a fresh session, until the handoff says stop.
#
# Usage:  tools/session/auto-session.sh            loop: start the next session, and when
#                                                 you leave it (/exit) start the one after
#         tools/session/auto-session.sh --once     start one session and stop
#         tools/session/auto-session.sh --dry-run  show what would start, start nothing
#
# Each round reads production/session-handoff.md (tracked in git):
#   - **Next prompt:** <id> | auto   -> production/session-prompts/session-<id>-*.md
#   - **Next machine:** linux | windows | any
#   - **Auto-continue:** yes | no
# and sends the first ``` block of that prompt file as the first message. Claude updates
# the handoff at the end of each session. The loop stops when Auto-continue is "no", the
# next session needs another machine, or a session ends without updating the handoff.
# Decisions are still asked in the session as usual; only the start is automated.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$root"
handoff="production/session-handoff.md"
prompts="production/session-prompts"
mode="${1:-loop}"

field() {  # field <name> -> value of "- **<name>:** value", first word only for ids
  sed -n "s/^- \*\*$1:\*\* *//p" "$handoff" | head -n1
}

this_machine="linux"
[[ "$(uname -s)" == MINGW* || "$(uname -s)" == MSYS* || "$(uname -s)" == CYGWIN* ]] && this_machine="windows"

while true; do
  [[ -f "$handoff" ]] || { echo "error: $handoff not found" >&2; exit 1; }
  next="$(field 'Next prompt' | awk '{print $1}')"
  machine="$(field 'Next machine' | awk '{print $1}')"
  auto="$(field 'Auto-continue' | awk '{print $1}')"
  updated="$(field 'Updated')"

  if [[ "$auto" != "yes" ]]; then
    echo "Handoff says Auto-continue: ${auto:-<missing>} — stopping." >&2
    exit 0
  fi
  if [[ "$machine" != "any" && "$machine" != "$this_machine" ]]; then
    echo "Next session ($next) needs a ${machine} machine; this is ${this_machine}." >&2
    echo "Commit and push here, then on that machine: git pull and run the auto-session script." >&2
    exit 0
  fi

  shopt -s nullglob
  matches=("$prompts"/session-"$next"-*.md)
  shopt -u nullglob
  if [[ ${#matches[@]} -ne 1 ]]; then
    echo "error: Next prompt '$next' must match exactly one $prompts/session-$next-*.md (found ${#matches[@]})" >&2
    exit 1
  fi
  file="${matches[0]}"
  prompt="$(awk '/^```/{n++; next} n==1' "$file")"
  [[ -n "${prompt//[[:space:]]/}" ]] || { echo "error: no \`\`\` block in $file" >&2; exit 1; }

  echo "=== Next session: $file (handoff updated: $updated)" >&2
  if [[ "$mode" == "--dry-run" ]]; then
    printf '%s\n' "$prompt"
    exit 0
  fi

  claude "$prompt" || true

  if [[ "$(field 'Updated')" == "$updated" ]]; then
    echo "The session ended without updating $handoff — stopping so nothing repeats." >&2
    echo "Re-run this script when ready (or edit the handoff by hand)." >&2
    exit 0
  fi
  [[ "$mode" == "--once" ]] && exit 0

  echo >&2
  echo "Handoff updated. Next session starts in 10 s — press q then Enter to stop." >&2
  if read -r -t 10 answer && [[ "$answer" == q* ]]; then
    echo "Stopped." >&2
    exit 0
  fi
done
