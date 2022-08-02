#!/usr/bin/env zsh

# Sourced from .zshrc or from Dotbot install scripts
# Sets INSTALL_TOOLS based on script argument.
# Tool scripts will use this value to only install tools when INSTALL_TOOLS=true
# When false, it only sets PATH and aliases which will speed up shell starts

if [[ $1 = 'true' ]]; then
  export INSTALL_TOOLS=true
else
  export INSTALL_TOOLS=false
fi

# Gather all source scripts by wildcard and source them
# See https://stackoverflow.com/a/14973302 for explanation
typeset -a sources
sources+=($DOTFILES/zsh/tools/*.zsh)
sources+=($DOTFILES/zsh/projects/*.zsh)
sources+=($DOTFILES/zsh/apps/*.zsh)

for f ($^sources(.N)) source $f;
unset sources

unset INSTALL_TOOLS
