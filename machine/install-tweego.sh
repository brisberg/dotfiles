#!/bin/sh
# Install Tweego (the Twine/Twee compiler) system-wide, at a pinned version.
#
# WHY THIS EXISTS
#
#   Spindle (~/DevProjects/spindle) shells out to `tweego` to compile Twee
#   sources into playable HTML. Without it on PATH, Spindle cannot build games.
#
# WHY NOT `go install`
#
#   `go install github.com/tmedwards/tweego@latest` is broken (as of 2026). The
#   repository moved from Bitbucket to GitHub, but its internal imports still use
#   the old bitbucket.org/tmedwards/tweego module path, so the module path in
#   go.mod does not match where it is fetched from. Hence the prebuilt release.
#
# WHY SYSTEM-WIDE (/usr/local/bin, not ~/.local/bin)
#
#   This machine has several macOS user accounts (different professional
#   contexts) and more than one of them needs Tweego. One copy in a shared
#   location is the point. /usr/local/bin is on the default PATH for every
#   account via /etc/paths, so nothing per-user has to be configured. This is
#   also why the script lives in machine/, outside the chezmoi source root: it
#   is run by hand, once per machine, and chezmoi never applies it. See
#   machine/README.md.
#
# WHY THE STORY FORMATS ARE NOT INSTALLED
#
#   The release zip bundles a storyformats/ directory of 2019-era formats, plus
#   licenses/. Both are deliberately left out. Each game repository commits its
#   own storyformats/ directory, pinned to the format version that game was
#   written against. A system-wide set of stale formats would only ever be
#   shadowed by those or, worse, silently picked up in their place.
#
# QUIRKS TO KNOW ABOUT
#
#   * Tweego refuses to run AT ALL, even for --version, if it finds no story
#     format search directory, and an empty directory does not count. So
#     `tweego --version` works only from a directory containing storyformats/,
#     or with TWEEGO_PATH pointing at one. This script therefore verifies the
#     installed file by SHA256, not by running it.
#   * `tweego --version` exits 1 even on success. Never use it as a pass/fail
#     check. The install-time smoke test below greps its output instead.
#   * The release is an x86-64 build and there is no arm64 one, so on Apple
#     Silicon it runs under Rosetta 2. The "-macos-x86" asset is 32-bit and will
#     not run on any current macOS; do not pick it.
#
# WHAT THE CHECKSUMS DO AND DO NOT PROVE
#
#   Upstream publishes no checksums. The hashes below were computed from a
#   download on 2026-09-30, so they prove "the same bytes I pinned", not that
#   upstream was trustworthy at the time. There is no way to do better.
#
# LONG-TERM RISK: ROSETTA
#
#   Apple has said Rosetta will be reduced after macOS 27. When that bites, this
#   binary stops running and there is no arm64 release to switch to. The exit is
#   building from source for arm64, which is blocked by the module-path problem
#   above (untested whether it can be worked around). Expect to revisit this
#   script then, not because of a new Tweego version: v2.1.1 was published
#   2020-02-25 and upstream has been quiet since.
#
# USAGE
#
#   ./install-tweego.sh                    install, or confirm already installed
#   ./install-tweego.sh --print-hashes 2.1.1   print the pins for a version
#
#   Safe to re-run. When the installed binary already matches BIN_SHA256 it
#   exits immediately with no network access and no sudo. sudo is used only for
#   the final copy into /usr/local/bin.
#
# UPGRADING
#
#   1. Run `--print-hashes <new version>` and paste the output below.
#   2. Bump VERSION, ZIP_SHA256 and BIN_SHA256 together.
#   3. Re-run this script on each machine.
#
# UNINSTALLING
#
#   sudo rm /usr/local/bin/tweego

set -eu

VERSION=2.1.1
ZIP_SHA256=93d8da9df25e6b08d9011175ecebe67bef76a639f3aa3b20b5deefb691316ef1
BIN_SHA256=0a15739fd971fb0e50917d6c8c5f917283311cca4e6aaed5d910782730582824

DEST=/usr/local/bin/tweego

sha256() { shasum -a 256 "$1" | awk '{print $1}'; }

die() { echo "install-tweego: $*" >&2; exit 1; }

[ "$(uname -s)" = Darwin ] ||
  die "macOS only. The Linux release asset follows the same naming pattern but has not been verified; add it when it is needed."

url() { echo "https://github.com/tmedwards/tweego/releases/download/v$1/tweego-$1-macos-x64.zip"; }

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

if [ "${1:-}" = "--print-hashes" ]; then
  [ -n "${2:-}" ] || die "usage: $0 --print-hashes <version>"
  curl -fsSL -o "$tmp/tweego.zip" "$(url "$2")"
  unzip -q "$tmp/tweego.zip" tweego -d "$tmp/bin"
  echo "VERSION=$2"
  echo "ZIP_SHA256=$(sha256 "$tmp/tweego.zip")"
  echo "BIN_SHA256=$(sha256 "$tmp/bin/tweego")"
  exit 0
fi

# Already installed and exact? Hash comparison is independent of cwd and of the
# exit code of --version, and detects a modified file as well as a wrong version.
if [ -f "$DEST" ] && [ "$(sha256 "$DEST")" = "$BIN_SHA256" ]; then
  echo "tweego $VERSION already installed at $DEST"
  exit 0
fi

# `arch -x86_64` fails on Apple Silicon without Rosetta. Better to say so here
# than to install a binary that dies with "Bad CPU type in executable".
arch -x86_64 /usr/bin/true 2>/dev/null ||
  die "cannot run x86-64 binaries. Install Rosetta: softwareupdate --install-rosetta --agree-to-license"

echo "Downloading tweego $VERSION ..."
curl -fsSL -o "$tmp/tweego.zip" "$(url "$VERSION")"

# Verify before extracting anything from the archive.
[ "$(sha256 "$tmp/tweego.zip")" = "$ZIP_SHA256" ] ||
  die "zip checksum mismatch; refusing to extract"

# Only the binary is installed. storyformats/ is extracted into the temp dir
# solely so the smoke test has a format directory to satisfy Tweego's startup
# check; it is discarded with the temp dir.
unzip -q "$tmp/tweego.zip" tweego 'storyformats/*' -d "$tmp/x"
[ "$(sha256 "$tmp/x/tweego")" = "$BIN_SHA256" ] ||
  die "extracted binary checksum mismatch; refusing to install"
# The zip does not preserve the execute bit, so the extracted file is not
# runnable as-is. File mode is not covered by the checksum.
chmod 755 "$tmp/x/tweego"

# Smoke test: does it actually execute here (Rosetta present, Gatekeeper not
# killing it)? Exit status is ignored on purpose; see QUIRKS above.
out=$(cd "$tmp" && TWEEGO_PATH="$tmp/x/storyformats" "$tmp/x/tweego" --version 2>&1 || true)
echo "$out" | grep -q "version $VERSION" ||
  die "downloaded binary did not report version $VERSION. Output was: $out"

echo "Installing to $DEST (sudo) ..."
sudo install -d -m 755 "$(dirname "$DEST")"
sudo install -m 755 -o root -g wheel "$tmp/x/tweego" "$DEST"

[ "$(sha256 "$DEST")" = "$BIN_SHA256" ] ||
  die "installed file does not match the pinned checksum"

echo "tweego $VERSION installed at $DEST"
