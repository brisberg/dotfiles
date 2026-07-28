# Git Configs

[Git](https://git-scm.com/) is a Version Control System which comes with a Command Line Interface which can be configured based on a [gitconfig](https://git-scm.com/docs/git-config) file.

This file is loaded automatically from `~/.gitconfig`, but it can include other config files using the `includeIf` [directive](https://git-scm.com/docs/git-config#_includes).

The root `gitconfig` file will be symlinked from `~/.gitconfig` and may optionally include other configuration files in this directory, referenced by `$DOTFILES/gitconfigs/<configname>.conf`.

See blog post for explanation.

## Private Settings

For sensitive configurations not appropriate for committing to version control, the base config will include `~/.git-private.conf`. It is up to the user to setup this script as appropriate for the host environment.

The same applies to any directory-scoped identity referenced by an `includeIf`
whose target lives outside this repo. Git silently ignores an `includeIf` whose
path does not exist, so a host that does not need a given identity requires no
configuration at all.
