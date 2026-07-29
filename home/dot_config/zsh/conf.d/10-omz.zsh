# Oh My Zsh — https://ohmyz.sh/
#
# Previously a git submodule under the repo, which was never initialised, so
# this framework had not actually been loading. It is now a chezmoi external.
#
# The upstream template's large block of commented-out options was dropped when
# this moved here; every one of them was disabled. Refer to the current upstream
# template if a setting is wanted:
# https://github.com/ohmyzsh/ohmyzsh/blob/master/templates/zshrc.zsh-template

# This path must match the .chezmoiexternal.toml entry exactly. That entry is
# resolved relative to $HOME, so it is spelled out literally here rather than
# via XDG_DATA_HOME, which the surrounding environment could have pointed
# somewhere else.
export ZSH="$HOME/.local/share/oh-my-zsh"

# Degrade gracefully. A host part-way through migration, or one where the
# external has not been fetched yet, should still get a working shell rather
# than a wall of errors.
if [[ ! -d $ZSH ]]; then
  print -u2 "oh-my-zsh not found at $ZSH — skipping (try: chezmoi apply)"
  return 0
fi

ZSH_THEME="robbyrussell"
plugins=(git)

# chezmoi owns this checkout and refreshes it on the schedule in
# .chezmoiexternal.toml. Leaving oh-my-zsh's own updater enabled would mean two
# things pulling the same repository, and its interactive update prompt would
# appear in new shells.
zstyle ':omz:update' mode disabled

source "$ZSH/oh-my-zsh.sh"
