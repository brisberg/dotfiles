# Sourced from .zshrc
# Place all zsh aliases in this file

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.

# Dotfiles
alias dotfiles-install="(cd $DOTFILES; git checkout $HOST_SHORT; git pull -r; sh $DOTFILES/install)"

# Git aliases
# TODO(brisberg): Possibly remove these if they conflict with omz/git plugin. Document that somewhere
alias gs="git status"
alias gci="git commit"
alias gcim="git commit -m"
alias gaa="git add ."
alias gap="git add -p"
alias grbc="git rebase --continue"
alias grba="git rebase --abort"
alias gl="git log --all --graph --decorate --oneline --simplify-by-decoration"

# Standard Shell Environment aliases
alias path-pretty-print='echo "$PATH" | tr ":" "\n"'
alias ppath=path-pretty-print
