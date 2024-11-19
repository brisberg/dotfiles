# Sourced from zsh/install-tools.zsh
# Configs for interacting with GitHub from the CLI
# https://github.com/

# Add GitHub Host to ~/.ssh/config if it is missing
touch ~/.ssh/config
grep -qxF 'Host github.com' ~/.ssh/config || echo '''Host github.com
  User git
  IdentityFile ~/.ssh/github_rsa''' >> ~/.ssh/config