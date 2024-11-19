# Sourced from zsh/install-tools.zsh
# Homebrew package manager for OSX
# https://brew.sh/

HOMEBREW_PREFIX=/opt/homebrew

if [[ $INSTALL_TOOLS = true ]]; then
  ## Homebrew installed by Strap on initial bootstrap.
  ## Assumed to be always present
  if (( ${+commands[brew]} )); then
    print "Homebrew already installed at: $(which brew)"
  else
    print "Please install Homebrew to '${HOMEBREW_PREFIX}'. See Strap for install options."
  fi
fi

## Add local homebrew installation to PATH
export PATH=$HOMEBREW_PREFIX/bin:$PATH