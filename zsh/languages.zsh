# Sourced from .zshrc
# Sets any programming language configuration, variables, or tools here

## Python https://www.python.org/

### Virtualenv config
export WORKON_HOME=~/.virtualenvs
omz plugin load virtualenvwrapper


## Golang https://go.dev/
export GOPATH="$HOME/go"


## Java https://www.java.com/en/
export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)


## Rust https://www.rust-lang.org/
export PATH="$HOME/.cargo/bin:$PATH"
