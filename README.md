# dotfiles

Personal dotfile repository

### Install

Clean install:

```
git clone https://github.com/brisberg/dotfiles.git
cd dotfiles
git submodules update --init
```

### Homebrew

Brewfile represents currently installed programs and utilities.
Use `brew bundle --global` to install all fresh casks.

### Branch Structure

This repo uses a branching strategy to manage related configuration changes between hosts.

`main` - Core configs common to all hosts. Majority of configurations should go here.
`${hostname -s}` - A series of branches for each host I manage. Each host should checkout the branch of them.

Making changes to the `main` branch should then be merged / cherrypicked into a host branch.

I will need to document here how these branches are linked, and possibly provide script aliases for making the updates easier.

Note:
In the future I may create a more complext tiered approach. For example have a `linux_64` branch which is common to all Linux hosts, and each linux host branch should base off that instead of `main`.
