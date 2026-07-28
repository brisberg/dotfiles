# Oh My Zsh — https://ohmyz.sh/
#
# Previously a git submodule under the repo. Stage 6 replaces that with a
# chezmoi external checked out to the path below.
#
# The upstream template's large block of commented-out options was dropped when
# this moved here; every one of them was disabled. Refer to the current upstream
# template if a setting is wanted:
# https://github.com/ohmyzsh/ohmyzsh/blob/master/templates/zshrc.zsh-template

export ZSH="$XDG_DATA_HOME/oh-my-zsh"

# Degrade gracefully. A host part-way through migration, or one where the
# external has not been fetched yet, should still get a working shell rather
# than a wall of errors.
if [[ ! -d $ZSH ]]; then
  print -u2 "oh-my-zsh not found at $ZSH — skipping (try: chezmoi apply)"
  return 0
fi

ZSH_THEME="robbyrussell"
plugins=(git)

source "$ZSH/oh-my-zsh.sh"
