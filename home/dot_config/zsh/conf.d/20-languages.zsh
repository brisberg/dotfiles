# Programming language toolchains.
# Environment only — installation belongs in a chezmoi script, not in shell
# startup.

## Python — https://www.python.org/
if [[ -f /usr/local/bin/virtualenvwrapper.sh ]]; then
  export WORKON_HOME="$HOME/.virtualenvs"
  (( $+commands[omz] )) && omz plugin load virtualenvwrapper
fi

## Go — https://go.dev/
export GOPATH="$HOME/go"

## Rust — https://www.rust-lang.org/
# PATH entry is handled in 00-path.zsh.

## Node — https://github.com/nvm-sh/nvm
# Moved here from zprofile. On WSL zsh is not a login shell, so zprofile never
# ran and nvm silently failed to load — which is exactly what the commented-out
# "Cerberus-PC" block in the old zshrc was working around. Loading it from
# zshrc fixes both hosts and removes the need for the conditional entirely.
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

## Java — https://www.java.com/
# The previous JAVA_HOME block was dead: its only statement was commented out,
# leaving an if/fi that set nothing. Removed rather than carried forward. To
# restore it:
#     export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
