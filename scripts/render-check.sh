#!/usr/bin/env bash
# Render every host profile and assert on the OUTPUT.
#
# Asserting on output rather than on exit codes is not pedantry here. When a
# prompt goes unanswered non-interactively, chezmoi substitutes the prompt text
# itself as the value and exits 0 — so a typo produces a config containing
# hostID = "host slug" and a perfectly green build. Check 2 below exists
# specifically to catch that.
#
# Runs identically on a laptop and in CI. No arguments.

set -uo pipefail

CHEZMOI="${CHEZMOI:-$(command -v chezmoi || true)}"
if [ -z "$CHEZMOI" ]; then
  echo "chezmoi not found on PATH" >&2
  exit 127
fi

REPO=$(cd "$(dirname "$0")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

failures=0
fail() { echo "  FAIL: $*" >&2; failures=$((failures + 1)); }
pass() { echo "  ok: $*"; }

# profile | slug | synthetic host TOML (empty = defined in hosts.toml) | brewfile | casks | bashrc
PROFILES=(
  "macos-gui|angler||yes|yes|no"
  "wsl|cerberus||no|no|yes"
  "macos-headless|ci-macos-headless|class = \"macos\"\ngui = false|yes|no|no"
  "linux|ci-linux|class = \"linux\"\ngui = false|no|no|yes"
)

for entry in "${PROFILES[@]}"; do
  IFS='|' read -r profile slug synthetic want_brewfile want_casks want_bashrc <<<"$entry"
  echo
  echo "=== profile: $profile (slug=$slug) ==="

  cfg="$TMP/$profile.toml"
  dest="$TMP/$profile/home"
  mkdir -p "$dest"

  cat >"$cfg" <<EOF
[data]
hostID = "$slug"
gitName = "ci-test"
gitEmail = "ci@example.invalid"
EOF
  if [ -n "$synthetic" ]; then
    printf '[data.hosts.%s]\n' "$slug" >>"$cfg"
    printf '%b\n' "$synthetic" >>"$cfg"
  fi

  if ! "$CHEZMOI" --source "$REPO" --config "$cfg" --destination "$dest" \
       apply --exclude=scripts,externals 2>"$TMP/$profile.err"; then
    # Skip warning lines. chezmoi emits "config file template has changed"
    # because this script writes the config directly rather than via
    # `chezmoi init`, and that noise would otherwise be reported as the cause.
    fail "apply failed: $(grep -v 'warning:' "$TMP/$profile.err" | head -1)"
    continue
  fi
  pass "apply succeeded"

  # 1. Host identity actually baked in.
  if grep -q "export HOST_ID=\"$slug\"" "$dest/.zshenv"; then
    pass "HOST_ID rendered"
  else
    fail "HOST_ID not rendered into .zshenv"
  fi

  # 2. The silent-substitution trap. A prompt string appearing as a VALUE means
  #    a prompt went unmatched and chezmoi filled in the prompt text.
  if grep -rqE '"(host slug|git name|git email)"' "$dest" 2>/dev/null; then
    fail "a prompt string was substituted as a value (unmatched --promptString)"
  else
    pass "no prompt-string substitution"
  fi

  # 3. Brewfile present only where Homebrew applies.
  if [ -f "$dest/.Brewfile" ]; then
    [ "$want_brewfile" = yes ] && pass ".Brewfile present" || fail ".Brewfile present but should not be"
  else
    [ "$want_brewfile" = no ] && pass ".Brewfile correctly absent" || fail ".Brewfile missing but expected"
  fi

  # 4. Casks only on GUI hosts.
  casks=0
  [ -f "$dest/.Brewfile" ] && casks=$(grep -c '^cask ' "$dest/.Brewfile" || true)
  if [ "$want_casks" = yes ]; then
    [ "$casks" -gt 0 ] && pass "casks present ($casks)" || fail "expected casks, found none"
  else
    [ "$casks" -eq 0 ] && pass "no casks (headless)" || fail "found $casks casks on a headless profile"
  fi

  # 4b. The bash handoff shim belongs only where bash is the login shell.
  if [ -f "$dest/.bashrc" ]; then
    [ "$want_bashrc" = yes ] && pass ".bashrc present" || fail ".bashrc present but should not be"
  else
    [ "$want_bashrc" = no ] && pass ".bashrc correctly absent" || fail ".bashrc missing but expected"
  fi

  # 5. Git identity, tested functionally rather than textually.
  #
  #    Identity now comes from a directory-scoped includeIf, and git evaluates
  #    those only against a real repository at a real path. `git config --file`
  #    would report nothing and pass regardless, so this builds throwaway repos
  #    under a HOME pointed at the rendered tree.
  #
  #    XDG_CONFIG_HOME and GIT_CONFIG_GLOBAL are unset explicitly. Either one
  #    silently substitutes the developer's own git config for the rendered one,
  #    which is a contamination that makes this check pass for the wrong reason
  #    — it has already happened once while developing it.
  gitenv() { env -u XDG_CONFIG_HOME -u GIT_CONFIG_GLOBAL HOME="$dest" "$@"; }

  #    (a) Mapped tree: the rendered identity applies.
  mkdir -p "$dest/DevProjects/probe"
  gitenv git -C "$dest/DevProjects/probe" init -q 2>/dev/null
  got=$(gitenv git -C "$dest/DevProjects/probe" config --get user.email 2>/dev/null || true)
  [ "$got" = "ci@example.invalid" ] &&
    pass "identity resolves under DevProjects" ||
    fail "DevProjects identity wrong: '$got'"

  #    (b) Unmapped tree: git must REFUSE. This is user.useConfigOnly doing its
  #        job — without it git invents an identity from $USER and the hostname
  #        and commits happily under the wrong name.
  mkdir -p "$dest/unmapped/probe"
  gitenv git -C "$dest/unmapped/probe" init -q 2>/dev/null
  if gitenv git -C "$dest/unmapped/probe" commit -q --allow-empty -m probe >/dev/null 2>&1; then
    fail "an unmapped directory was committable; useConfigOnly is not in effect"
  else
    pass "unmapped directory refuses to commit"
  fi

  #    (c) The local.conf seam. The private layer's entire contract is that it
  #        can add an identity for a tree the public repo has never heard of.
  #        Tested with a deliberately meaningless tree name: this file must not
  #        record the name of any real private tree, and does not need to in
  #        order to prove the mechanism.
  mkdir -p "$dest/Elsewhere/probe" "$dest/.config/git"
  cat >"$dest/.config/git/local.conf" <<EOF
[includeIf "gitdir/i:~/Elsewhere/"]
	path = ~/.config/git/elsewhere.conf
EOF
  cat >"$dest/.config/git/elsewhere.conf" <<EOF
[user]
	name = seam-probe
	email = seam@example.invalid
EOF
  gitenv git -C "$dest/Elsewhere/probe" init -q 2>/dev/null
  got=$(gitenv git -C "$dest/Elsewhere/probe" config --get user.email 2>/dev/null || true)
  [ "$got" = "seam@example.invalid" ] &&
    pass "local.conf can add an identity for an unknown tree" ||
    fail "local.conf seam broken: '$got'"
  rm -f "$dest/.config/git/local.conf" "$dest/.config/git/elsewhere.conf"

  # 6. Every rendered zsh file parses.
  bad=0
  while IFS= read -r f; do
    zsh -n "$f" 2>/dev/null || { fail "zsh syntax error in ${f#"$dest"}"; bad=1; }
  done < <(find "$dest" -type f \( -name '*.zsh' -o -name '.zshrc' -o -name '.zshenv' \))
  [ "$bad" -eq 0 ] && pass "all zsh files parse"

  # 6b. Bash files too, where they exist.
  bad=0
  for bf in "$dest/.bashrc" "$dest/.bash_profile"; do
    [ -f "$bf" ] || continue
    bash -n "$bf" 2>/dev/null || { fail "bash syntax error in ${bf#"$dest"}"; bad=1; }
  done
  [ "$bad" -eq 0 ] && pass "bash files parse (or absent)"

  # 7. Every rendered script parses. Scripts are executed rather than written to
  #    the destination, so render them explicitly.
  bad=0
  for tmpl in "$REPO"/home/.chezmoiscripts/*.tmpl; do
    [ -e "$tmpl" ] || continue
    if ! "$CHEZMOI" --source "$REPO" --config "$cfg" --destination "$dest" \
         execute-template <"$tmpl" >"$TMP/script.sh" 2>/dev/null; then
      fail "script template failed to render: $(basename "$tmpl")"; bad=1; continue
    fi
    sh -n "$TMP/script.sh" || { fail "shell syntax error in $(basename "$tmpl")"; bad=1; }
  done
  [ "$bad" -eq 0 ] && pass "all scripts parse"
done

echo
if [ "$failures" -gt 0 ]; then
  echo "render-check: $failures failure(s)" >&2
  exit 1
fi
echo "render-check: all profiles OK"
