# Google Cloud SDK — https://cloud.google.com/sdk
#
# Installation moved to a chezmoi script (Stage 5). This file only wires up the
# shell, and only when the tool is actually present.

if (( $+commands[gcloud] )) && (( $+commands[omz] )); then
  omz plugin load gcloud
fi
