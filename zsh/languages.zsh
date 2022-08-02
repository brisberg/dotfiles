# Sourced from .zshrc
# Sets any programming language configuration, variables, or tools here

## Python https://www.python.org/

### Virtualenv config
if [[ -f /usr/local/bin/virtualenvwrapper.sh ]]; then
    export WORKON_HOME=~/.virtualenvs
    omz plugin load virtualenvwrapper
fi


## Golang https://go.dev/
export GOPATH="$HOME/go"


## Java https://www.java.com/en/
if [[ -f /usr/libexec/java_home ]]; then
    export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
fi


## Rust https://www.rust-lang.org/
export PATH="$HOME/.cargo/bin:$PATH"
