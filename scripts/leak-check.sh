#!/bin/sh
# Check staged changes against a list of forbidden patterns.
#
# The pattern list is deliberately NOT in this repository. It lives at the path
# below, which is untracked and supplied per host. When that file is absent this
# script is a no-op — the correct behaviour on a machine that has nothing
# sensitive to protect.
#
# This script never prints a pattern, a matching line, or a filename. It reports
# a pattern's line number in the list and a count, which is enough to find the
# problem on the machine that already has the list, and useless anywhere else.
# That restraint is the entire point: logs from a public repository are public,
# and a leak detector that prints what it found would publish the thing it was
# meant to protect.
#
# Install:  ./scripts/install-hooks.sh
# Bypass:   git commit --no-verify   (deliberate, and your responsibility)

set -eu

PATTERNS_FILE="${DOTFILES_FORBIDDEN_PATTERNS:-$HOME/.config/dotfiles/forbidden-patterns}"

if [ ! -f "$PATTERNS_FILE" ]; then
  exit 0
fi

# Only added or modified lines in the staged diff. Deletions are how a leak gets
# fixed, so flagging them would block the remedy.
added=$(git diff --cached -U0 --diff-filter=ACM | grep '^+' | grep -v '^+++' || true)

if [ -z "$added" ]; then
  exit 0
fi

status=0
lineno=0

while IFS= read -r pattern || [ -n "$pattern" ]; do
  lineno=$((lineno + 1))

  # Skip blanks and comments so the list can document itself.
  case "$pattern" in
    '' | '#'*) continue ;;
  esac

  count=$(printf '%s\n' "$added" | grep -c -i -E -e "$pattern" || true)

  if [ "$count" -gt 0 ]; then
    if [ "$status" -eq 0 ]; then
      echo "leak-check: staged changes match forbidden pattern(s)." >&2
      echo >&2
    fi
    echo "  pattern #$lineno — $count matching added line(s)" >&2
    status=1
  fi
done < "$PATTERNS_FILE"

if [ "$status" -ne 0 ]; then
  cat >&2 <<EOF

Nothing further is printed here on purpose; the patterns are the sensitive part.
To see what matched, on this machine only:

  sed -n "\${N}p" "$PATTERNS_FILE"          # the pattern for a given #N
  git diff --cached | grep -inE "\$(sed -n "\${N}p" "$PATTERNS_FILE")"

Commit refused.
EOF
fi

exit "$status"
