# Z Shell Configuration

[Zsh](https://www.zsh.org/) is a popular shell alterative to [Bash](https://www.gnu.org/software/bash/). Though it has many similarities as they are both based on the Unix Shell, Zsh has many of its own idiosyncrasies.

Apple has [officially switched](https://support.apple.com/en-us/HT208050) the default shell on OSX.

## Oh My Zsh

[Oh My Zsh](https://ohmyz.sh/) is a delightful, open source, community-driven framework for managing your Zsh configuration. It comes bundled with thousands of helpful functions, helpers, plugins, themes.

It is installed a submodule in this repo and used heavily for maintaining useful configuration.

## Environment Variables

My Zsh setup exports the following Environment Variables:

| Name     | Example Value | Purpose                                           |
| -------- | ------------- | ------------------------------------------------- |
| DOTFILES | ~/.dotfiles   | Absolute directory root for dotfile installation. |

## File Structure

I've split up my Zsh configuration into numerous files for maintainability by making sure that each file is doing just one thing.

A general overview of how these scripts are organized and actually [executed](https://zsh.sourceforge.io/Intro/intro_3.html) in a shell:

- `zprofile` (`~/.zprofile`) - Executed for each login shell (even of SSH) before `.zshrc`
- `zshrc` (`~/.zshrc`) - Core entry point to user configuration. Executed for every interactive shell.
  - `oh-my-zsh.zsh` - Sets OhMyZsh specific configuration variables and invokes OhMyZsh.
  - `aliases.zsh` - Sets general purpose user specific aliases
  - `languages.zsh` - Sets environment variables to enable tooling for various Programming Languages.
  - `install-tools.zsh` - Can be invoked with a boolean argument to either install/update all tools or simply import their variables, aliases, and completions. Run with `false` in `zshrc` for faster shell startups.
    - `zsh/(tools|projects|alls)/*` - Collected and executed by `install-tools.zsh`. See Tool Scripts below.

`zprofile` and `zshrc` are the only files symlinked into HOME directory to be picked up automatically by the shell.

### Tool Scripts

Tool scripts are located under `zsh/tools` or `zsh/projects` or `zsh/apps`.
These buckets roughly correspond to "programs used to perform other tasks", "Workspace settings for a particular project (i.e. Mods for a game), and "Applications directly used by the user".

Each script manages the installation/update of a particular program or workspace. They read the `INSTALL_TOOLS` environment variable to determine if they should perform a potentially time consuming install action. They always export aliases/environment variables required for using the installed tool.

Generally Tool Scripts will have this structure:

```
# Foobar Tool configs
# https://foobar.com/site

# Conditionally,  Update or install tool. This may be slow if it requires a network lookup or file download.
# Should not through any errors if the program is already installed.
if [[ INSTALL_TOOLS = 'true' ]]; then
  brew install -q foobar
fi

# Always export environment variable or shell configurations to use the program, assume it has already been installed.
# For example:
# Enable OhMyZsh plugin to enable completions
omz plugin load foobar-cli
alias foobar=/path/to/foobar-cli
```
