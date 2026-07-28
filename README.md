# dotfiles

Personal dotfile repository

Uses [Dotbot](https://github.com/anishathalye/dotbot) to manage and version `.dotfiles`.

### Why chezmoi (migration in progress)

This repo is moving from [Dotbot](https://github.com/anishathalye/dotbot) to
[chezmoi](https://www.chezmoi.io/). Recorded here for posterity, since the
reasoning is easy to forget once the migration is done.

Dotbot is a symlink manager, and it is a good one. But it has no notion of a
file whose *contents* differ between machines, and that turned out to be the
thing this repo actually needed:

- **Host variance had nowhere to live.** Per-host differences accumulated as
  commented-out blocks guarded by hand (`# For Cerberus-PC`). Every new host
  made every config file longer and more conditional, and a block was only ever
  correct on one machine at a time.
- **Branch-per-host did not scale.** Keeping a branch per machine meant every
  common change had to be merged or cherry-picked outward, and the branches
  drifted. Host differences are *data*, not history, and modelling them as
  history was the original mistake.
- **One machine, several users.** Separate users on the same host need separate
  identities from the same repo. With symlinks they would share a file; with
  templates each user renders their own from local, untracked config.
- **Detected hostnames are not stable.** macOS rewrites the short hostname on
  network changes, so keying anything off `hostname -s` is unreliable. Identity
  now comes from an explicit slug set once per machine.
- **Rollback becomes deterministic.** chezmoi writes file contents rather than
  symlinks, so the state of a machine is a pure function of a commit:
  `git revert` then `chezmoi apply`. Reverting a symlink farm silently changes
  live config with no diff step in between.
- **Extension points instead of edits.** Configs load host-local drop-ins
  (`~/.config/zsh/local.d/`, `~/.config/git/local.conf`) that this repo does not
  manage, so a machine can add to its configuration without forking it.

The cost, honestly stated: chezmoi copies files instead of symlinking them, so
editing `~/.zshrc` no longer edits the repo. Use `chezmoi edit` and
`chezmoi apply`. That is a real habit change and the main thing given up.

### Checks

Two things guard this repo, both runnable by hand:

```
./scripts/render-check.sh    # render every host profile and assert on the output
./scripts/install-hooks.sh   # enable the tracked pre-commit hook (idempotent)
```

`render-check.sh` renders every host profile — macOS with and without a GUI,
WSL, Linux — and asserts on what comes out: that host identity is baked in, that
platform-specific files appear only where they belong, that every rendered shell
file parses. It asserts on *output* rather than exit codes, because an
unanswered prompt in non-interactive mode does not fail; chezmoi substitutes the
prompt text as the value and exits successfully. CI runs this same script, so a
green build can be reproduced locally before pushing.

`leak-check.sh` runs from the pre-commit hook and refuses commits whose staged
changes match a list of strings you do not want published. That list is *not* in
this repository — it lives at `~/.config/dotfiles/forbidden-patterns`, one
regex per line, and the check is a silent no-op when the file is absent. The
script never prints a pattern, a matching line, or a filename; it reports a
count and a line number, which is enough to find the problem on the machine that
already has the list and useless anywhere else.

### Install

Clean install:

```
git clone https://github.com/brisberg/dotfiles.git
cd dotfiles
git checkout ${hostname -s} # checkout machine specific version
sh ./install
```

### Branch Structure

This repo uses a branching strategy to manage related configuration changes between hosts.

`main` - Core configs common to all hosts. Majority of configurations should go here.
`${hostname -s}` - A series of branches for each host I manage. Each host should checkout the branch of them.

Making changes to the `main` branch should then be merged / cherry-picked into a host branch.

I will need to document here how these branches are linked, and possibly provide script aliases for making the updates easier.

Note:
In the future I may create a more complex tiered approach. For example have a `linux_64` branch which is common to all Linux hosts, and each linux host branch should base off that instead of `main`.

### Homebrew

Brewfile represents currently installed programs and utilities.
Use `brew bundle --global` to install all fresh casks.
