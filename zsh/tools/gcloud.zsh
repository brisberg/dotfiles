# Sourced from .zshrc
# Google Cloud SDK configs
# https://cloud.google.com/sdk

if [ $INSTALL_TOOLS = true ]; then
  if (( ${+commands[brew]} )); then
    brew install -q google-cloud-sdk
  else
    print "Google Cloud SDK could not install. Please install Homebrew."
  fi
fi

# Enable OhMyZsh plugin to enable completions
if (( $+commands[omz] )); then
  omz plugin load gcloud
fi
