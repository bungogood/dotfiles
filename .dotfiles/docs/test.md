# Installer Test Notes

This is the quick way to test `.dotfiles/install.sh` safely without touching your real home directory.

## Why this works

The installer uses `$HOME` as the Git work tree. If we point `$HOME` to a temporary folder, we can run realistic tests with no risk to your real dotfiles.

## 1) Fresh install test

```bash
tmp_home="$(mktemp -d /tmp/dotfiles-test.XXXXXX)"
HOME="$tmp_home" bash "$PWD/.dotfiles/install.sh"

ls -la "$tmp_home"
```

Expected:
- `.dotfiles/` exists
- `.bashrc` exists
- `.gitconfig` and `.tmux.conf` exist
- `.bash_completion.d/config` exists

## 2) Conflict backup test

```bash
tmp_home="$(mktemp -d /tmp/dotfiles-conflict.XXXXXX)"
touch "$tmp_home/README.md" "$tmp_home/LICENSE"

HOME="$tmp_home" bash "$PWD/.dotfiles/install.sh"

ls -la "$tmp_home/.dotfiles.bak"*
```

Expected:
- conflict files moved into `.dotfiles.bak` (or `.dotfiles.bak.N`)
- tracked files still checked out afterwards

## 3) Broken symlink conflict test

```bash
tmp_home="$(mktemp -d /tmp/dotfiles-broken-link.XXXXXX)"
ln -s .dotfiles/README.md "$tmp_home/README.md"
ln -s .dotfiles/LICENSE "$tmp_home/LICENSE"

HOME="$tmp_home" bash "$PWD/.dotfiles/install.sh"

ls -la "$tmp_home/.dotfiles.bak"*
```

Expected:
- broken symlinks are treated as conflicts and backed up
- install completes

## 4) Basic status checks

```bash
tmp_home="/tmp/dotfiles-test.<id>"
/usr/bin/git --git-dir="$tmp_home/.dotfiles" --work-tree="$tmp_home" status --short --branch
/usr/bin/git --git-dir="$tmp_home/.dotfiles" config --get status.showUntrackedFiles
```

Expected:
- clean tracked state (or only intentional local differences)
- `status.showUntrackedFiles` is `no`

## 5) Cleanup

```bash
rm -rf /tmp/dotfiles-test.* /tmp/dotfiles-conflict.* /tmp/dotfiles-broken-link.*
```

## Notes

- Run commands from repo root (`~/projects/dotfiles`).
- Prefer `bash "$PWD/.dotfiles/install.sh"` during development so you test local changes before pushing.
- Use curl only when validating what is currently on GitHub.
