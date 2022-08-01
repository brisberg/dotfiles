# Sourced from .zshrc
# Don't Starve and Don't Starve Together game/mod configs
# https://www.klei.com/games/dont-starve
# Sets up env variables, aliases, and symlinks for playing and working with mods

alias gotods="cd $HOME/Library/Application\ Support/Steam/steamapps/common/dont_starve/dontstarve_steam.app/Contents"
alias gotodst="cd $HOME/Library/Application\ Support/Steam/steamapps/common/Don\'t\ Starve\ Together/dontstarve_steam.app/Contents"

# Don't Starve mod syncing
local MOD_PROJECT_DIR="$HOME/DevProjects"
local DS_MOD_DIR="$HOME/Library/Application\ Support/Steam/steamapps/common/dont_starve/dontstarve_steam.app/Contents/mods"
local DST_MOD_DIR="$HOME/Library/Application\ Support/Steam/steamapps/common/Don\'t\ Starve\ Together/dontstarve_steam.app/Contents/mods"

function sync_ds_mod() {
  rm -rf $DS_MOD_DIR/$1
  cp -R $MOD_PROJECT_DIR/$1/mod/ $DS_MOD_DIR/$1
}

function sync_dst_mod() {
  rm -rf $DST_MOD_DIR/$1
  cp -R $MOD_PROJECT_DIR/$1/mod/ $DST_MOD_DIR/$1
}
