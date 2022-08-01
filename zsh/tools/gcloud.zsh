# Sourced from .zshrc
# Google Cloud SDK configs
# https://cloud.google.com/sdk

# TODO: Test replacing these lines with the OMZ plugin
# https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/gcloud/gcloud.plugin.zsh
## omz plugin load gcloud

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Applications/google-cloud-sdk/path.zsh.inc' ]; then source '/Applications/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Applications/google-cloud-sdk/completion.zsh.inc' ]; then source '/Applications/google-cloud-sdk/completion.zsh.inc'; fi
