# Package maintenance

Run these commands from the repository root.

## Updating bundled source

`prepare-source.sh` creates an archive with fixed timestamps, ownership,
ordering, and permissions. After editing the source:

```sh
./prepare-source.sh
b2sum libfprint-goodix-5301-0.1.0.tar.gz
```

Copy the new archive checksum into the first `b2sums` entry in `PKGBUILD`.
Bump `pkgrel` for a package update, then regenerate metadata and the source
manifest:

```sh
makepkg --printsrcinfo > .SRCINFO
find source -type f -print0 | LC_ALL=C sort -z | xargs -0 sha256sum > SOURCE-MANIFEST.sha256
makepkg --verifysource
```

Build and test using [CONTRIBUTING.md](../CONTRIBUTING.md). Record hardware
results separately in [hardware.md](hardware.md).

## Publishing

Review the diff and commit the changes, then run:

```sh
./publish.sh
```

The script checks the authenticated `codeninjask` account, public destination
`codeninjask/goodix-5301-omarchy`, clean `main` branch, and remote URL before
pushing. It can also create the repository if it does not exist.

Review new files before committing. Keep fingerprint images and templates,
USB captures, private logs, vendor binaries, credentials, and machine-specific
PAM configuration out of the repository. Build outputs are ignored by Git.
Use `git ls-files` to inspect what is tracked; ignore rules do not remove
files already committed.
