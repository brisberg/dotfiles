# Sourced from .zshrc
# Godot Game Engine development configs
# https://godotengine.org/

# TODO: might be better to convert the Godot alias int a symlink on the path.
# See https://godotengine.org/qa/22104/how-to-run-a-project-in-godot-from-command-on-mac

# Assumes Godot was installed through Steam
local GODOT_ENGINE_PATH=$HOME/Library/Application\ Support/Steam/steamapps/common/Godot\ Engine/Godot.app/Contents/MacOS/Godot
if [[ -f "$GODOT_ENGINE_PATH" ]]; then
  # echo 'Godot Engine found'
  alias godot="'$GODOT_ENGINE_PATH'"
  # Run GUT Unit testing framework https://github.com/bitwes/Gut
  alias gut='godot --path $PWD -s addons/gut/gut_cmdln.gd'
fi
unset GODOT_ENGINE_PATH
