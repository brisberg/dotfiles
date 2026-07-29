#!/usr/bin/env bash
# Check that this host and user are correctly set up.
#
# Complements render-check.sh, which validates the repo in the abstract. This
# validates one live machine: that the apply landed, that nothing from a
# previous setup is shadowing it, and that identities resolve where they should.
#
# Run it as each user, on each host. No arguments, changes nothing.

set -uo pipefail

pass=0; warn=0; failn=0
ok()   { echo "  ok    $*"; pass=$((pass+1)); }
bad()  { echo "  FAIL  $*"; failn=$((failn+1)); }
note() { echo "  warn  $*"; warn=$((warn+1)); }

echo "=== chezmoi ==="
if ! command -v chezmoi >/dev/null 2>&1; then
  bad "chezmoi not on PATH"
else
  ok "chezmoi $(chezmoi --version | awk '{print $3}' | tr -d ',')"
  src=$(chezmoi source-path 2>/dev/null || echo "")
  if [ -n "$src" ] && [ -d "$src" ]; then ok "source: $src"; else bad "source path unresolved"; fi
  st=$(chezmoi status 2>/dev/null)
  if [ -z "$st" ]; then ok "status clean"; else
    note "pending changes:"; echo "$st" | sed 's/^/          /'
  fi
fi

echo
echo "=== leftovers from a previous setup ==="
# These shadow the new config silently rather than erroring, which is why they
# get their own section.
for f in "$HOME/.gitconfig" "$HOME/.zprofile" "$HOME/.dotfiles"; do
  if [ -e "$f" ] || [ -L "$f" ]; then
    bad "$f exists — it overrides or bypasses the managed config"
  else
    ok "$(basename "$f") absent"
  fi
done

echo
echo "=== git ==="
origin=$(git config --list --show-origin 2>/dev/null | grep -m1 'user\.email' | awk '{print $1}')
case "$origin" in
  *".config/git/config") ok "identity comes from the managed config" ;;
  "")                    bad "no user.email resolved at all" ;;
  *)                     bad "identity comes from $origin, not the managed config" ;;
esac
echo "        effective: $(git config --get user.name 2>/dev/null) <$(git config --get user.email 2>/dev/null)>"

echo
echo "=== shell ==="
if [ -n "${HOST_ID:-}" ]; then ok "HOST_ID=$HOST_ID (this shell)"; fi
out=$(zsh -i -l -c 'echo "HOST_ID=$HOST_ID"; echo "ZSH=$ZSH"; (( $+functions[omz] )) && echo OMZ_OK' 2>&1)
if echo "$out" | grep -qiE 'no such file|command not found|parse error'; then
  bad "a fresh login shell reports errors:"; echo "$out" | sed 's/^/          /'
else
  ok "fresh login shell is clean"
fi
echo "$out" | grep -q OMZ_OK && ok "oh-my-zsh loads" || bad "oh-my-zsh does not load"

echo
echo "=== drop-in seams (unmanaged by design; absent is fine) ==="
for d in "$HOME/.config/zsh/local.d" "$HOME/.ssh/config.d"; do
  n=$(ls -A "$d" 2>/dev/null | wc -l | tr -d ' ')
  [ -d "$d" ] && ok "$(basename "$d"): $n file(s)" || ok "$(basename "$d"): not present"
done
[ -f "$HOME/.config/git/local.conf" ] && ok "git local.conf present" || ok "git local.conf: not present"

echo
echo "=== leak guard ==="
pf="${DOTFILES_FORBIDDEN_PATTERNS:-$HOME/.config/dotfiles/forbidden-patterns}"
if [ -f "$pf" ]; then
  ok "pattern list present ($(grep -cvE '^\s*(#|$)' "$pf") active)"
  hp=$(git -C "${src:-$PWD}/.." config --get core.hooksPath 2>/dev/null || true)
  [ "$hp" = githooks ] && ok "pre-commit hook enabled" || bad "hooksPath is '${hp:-unset}', expected githooks"
else
  ok "no pattern list — leak-check no-ops (correct on a host with nothing to protect)"
fi

echo
echo "pass=$pass warn=$warn fail=$failn"
[ "$failn" -eq 0 ]
