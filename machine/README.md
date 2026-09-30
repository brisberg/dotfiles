# machine/

Scripts that change the **whole machine**, affecting every user account on it.

This directory is deliberately outside the chezmoi source root (`.chezmoiroot`
is `home`), so chezmoi never sees it and `chezmoi apply` never runs anything
here. That is the point: chezmoi runs as each individual user, and these scripts
need admin rights and apply to everyone.

Rules:

- Run by hand, once per machine, by an admin user. Re-running is always safe.
- Each script is idempotent and documents its own reasoning in its header; the
  header is the documentation.
- Nothing per-user belongs here. That goes in `home/`.
- Never commit binaries. Scripts download a pinned version and verify a
  checksum.

| Script | Installs |
| --- | --- |
| [install-tweego.sh](install-tweego.sh) | Tweego, the Twee compiler Spindle shells out to, in `/usr/local/bin` |
