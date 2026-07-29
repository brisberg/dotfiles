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

On a new host, one command. It installs chezmoi if needed, clones this repo,
prompts for the host slug and git identity, and applies everything:

```
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply brisberg/dotfiles
```

To keep the source where you already work, rather than chezmoi's default
`~/.local/share/chezmoi`:

```
git clone git@github.com:brisberg/dotfiles.git ~/DevProjects/dotfiles
chezmoi init --source ~/DevProjects/dotfiles --apply
```

The three prompts — host slug, git name, git email — are answered once per host
per user and stored in `~/.config/chezmoi/chezmoi.toml`, which is never
committed. That file is the entire mechanism by which one repo produces a
different result for each host and each user: the repo holds the logic, the
local config holds the answers.

A host slug must exist in [`home/.chezmoidata/hosts.toml`](home/.chezmoidata/hosts.toml).
An unknown one fails the apply with a message saying so.

### Day to day

```
chezmoi edit ~/.zshrc     # edit the source, not the copy in $HOME
chezmoi diff              # preview
chezmoi apply             # write it
chezmoi update            # git pull, then apply
chezmoi re-add ~/.zshrc   # pull a hand-edit in $HOME back into the source
```

Aliases for these are defined in
[`conf.d/40-aliases.zsh`](home/dot_config/zsh/conf.d/40-aliases.zsh.tmpl)
(`dotfiles-edit`, `dotfiles-diff`, `dotfiles-apply`, `dotfiles-update`).

The thing to internalise coming from a symlink manager: **editing a file in
`$HOME` does not edit the repo.** chezmoi writes copies. Use `chezmoi edit`, or
`chezmoi re-add` afterwards, or the change lives only in the generated copy and
the next apply reverts it.

### Adding configuration

Shell configuration goes in `home/dot_config/zsh/conf.d/`, numbered for load
order. Anything host-specific branches on a *capability* rather than a hostname:

```
{{ $host := index .hosts .hostID }}
{{ if $host.gui }} ... {{ end }}
```

Host-local additions that should not be committed go in
`~/.config/zsh/local.d/`, `~/.config/git/local.conf`, or `~/.ssh/config.d/`.
None of those are managed here, so they survive every apply.

### Homebrew

[`home/dot_Brewfile.tmpl`](home/dot_Brewfile.tmpl) renders to `~/.Brewfile`, with
GUI casks included only on hosts that have a display. `brew bundle --global`
works by hand; a chezmoi script runs it automatically when the package list
changes.
