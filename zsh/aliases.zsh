# Sourced from .zshrc
# Place all zsh aliases in this file

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
alias dotfiles-install="sh $DOTFILES/install"
alias zrc="subl ~/.zshrc"
alias szrc="source ~/.zshrc"

# Git aliases
alias gs="git status"
alias gci="git commit"
alias gcim="git commit -m"
alias gaa="git add ."
alias gap="git add -p"
alias grbc="git rebase --continue"
alias grba="git rebase --abort"
alias gl="git log --all --graph --decorate --oneline --simplify-by-decoration"
