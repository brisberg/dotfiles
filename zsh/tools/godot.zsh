# Sourced from .zshrc
# Godot Game Engine development configs
# https://godotengine.org/

# TODO: might be better to convert the Godot alias into a symlink on the path.
# See https://godotengine.org/qa/22104/how-to-run-a-project-in-godot-from-command-on-mac

# Absolute path to Godot installation
local GODOT_ENGINE_PATH=$HOME/path/to/godot/engine

if [[ -f "$GODOT_ENGINE_PATH" ]]; then
  # echo 'Godot Engine found'
  alias godot="'$GODOT_ENGINE_PATH'"
  # Run GUT Unit testing framework https://github.com/bitwes/Gut
  alias gut='godot --path $PWD -s addons/gut/gut_cmdln.gd'
fi
unset GODOT_ENGINE_PATH
