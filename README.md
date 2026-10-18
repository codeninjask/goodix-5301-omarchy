# Goodix 27c6:5301 for Arch Linux / Omarchy

Experimental libfprint driver, hardware tested on a **Dell Inspiron 5570** with
USB reader **27c6:5301** and firmware **GF3208_HT_APP_10035**. This is a community
port, not an official Dell or Goodix release. Other firmware and hardware have
not been validated. See [HARDWARE-TESTING.md](HARDWARE-TESTING.md).

## Fresh install

On an up-to-date x86_64 Omarchy/Arch system, run as your normal user:

```sh
sudo pacman -S --needed git && git clone https://github.com/codeninjask/goodix-5301-omarchy.git && cd goodix-5301-omarchy && ./install.sh
```

The installer checks the USB ID, builds the bundled source with `makepkg`, and
installs the driver and `fprintd`. It requests sudo for package operations.
Accept pacman's replacement of `libfprint` or `libfprint-git` with
`libfprint-goodix-5301`. This replaces the system libfprint library.

The source is included in this repository. Installation does not download a
driver tree or require Dell's Windows driver. `prepare-source.sh` generates a
deterministic local archive; the PKGBUILD verifies its checksum. Build products
and archives are ignored by Git.

Enroll and verify after installation:

```sh
fprintd-enroll
fprintd-verify
fprintd-list "$USER"
```

Use a clean, dry finger. Press and hold briefly, lift, then vary placement for
each of the 15 enrollment samples. Retry messages do not consume a stage.
Success is `enroll-completed`, followed by `verify-match` on verification.
A fresh system needs new enrollment; no saved fingerprints are included here.

**The installer does not configure PAM, sudo authentication, screen unlocking,
display-manager login, or browser authentication.** Keep password authentication
available. Enrollment and verification can be used before configuring any
authentication integration separately.

To build without installing:

```sh
./prepare-source.sh
makepkg --verifysource
makepkg --cleanbuild --syncdeps
meson test -C src/build --print-errorlogs
```

`makepkg --syncdeps` can install build dependencies. To install the built package
later, use `makepkg --install`. Do not build as root.

## Optional Omarchy menu

The Omarchy version tested here checks for the exact package name
`libfprint-git` in its stock fingerprint setup command. That command can replace
this driver. Use the provided menu extension or the `fprintd-*` commands instead.
Menu APIs may change in future Omarchy releases.

The files under `integration/` preserve the working native menu helper and
update safeguards. To install the menu helpers manually:

```sh
install -Dm755 integration/manage-fingerprints.sh "$HOME/.local/bin/goodix5301-settings"
install -Dm755 integration/check-reader.sh "$HOME/.local/libexec/goodix5301/check-reader.sh"
```

Merge the entries in [integration/omarchy-menu.json](integration/omarchy-menu.json)
into `~/.config/omarchy/extensions/omarchy-menu.jsonc`, preserving any existing
entries. On a fresh system where that file does not exist, copy the template:

```sh
mkdir -p "$HOME/.config/omarchy/extensions"
cp -n integration/omarchy-menu.json "$HOME/.config/omarchy/extensions/omarchy-menu.jsonc"
```

Open **Setup → Security → Fingerprint** to add, verify, list, or check prints.
The extension uses the user configuration directory; it does not modify
`/usr/share/omarchy` or authentication settings.

## Optional update safeguards

After installing the menu helpers, install the post-update health notification:

```sh
omarchy hook install post-update integration/goodix5301-health.hook
```

To prevent package transactions from replacing this driver with stock libfprint:

```sh
sudo install -Dm755 integration/protect-driver.sh /usr/local/libexec/goodix5301-protect-driver
sudo install -Dm644 integration/05-goodix5301-preserve-driver.hook /etc/pacman.d/hooks/05-goodix5301-preserve-driver.hook
```

The pacman hook aborts a replacement transaction before package changes. Review
such updates manually. Dependency/ABI changes may require rebuilding this
package; the safeguards cannot guarantee compatibility with future updates.

## Troubleshooting and rollback

Read-only checks:

```sh
lsusb -d 27c6:5301
pacman -Q libfprint-goodix-5301 fprintd
systemctl status fprintd.service --no-pager
journalctl -b -u fprintd.service --no-pager
```

The daemon is normally D-Bus activated. Firmware other than
`GF3208_HT_APP_10035` is deliberately rejected. Reboot if the reader becomes
unresponsive. Do not flash firmware as part of installation or troubleshooting.
Review diagnostics locally; never publish fingerprint frames, templates, or USB
captures. See [PUBLISHING.md](PUBLISHING.md) for the repository exclusions.

For an intentional rollback, first disable the optional replacement guard if
installed, then restore Arch's standard library:

```sh
sudo mv /etc/pacman.d/hooks/05-goodix5301-preserve-driver.hook /etc/pacman.d/hooks/05-goodix5301-preserve-driver.hook.disabled
sudo pacman -S libfprint
```

Skip the `mv` command if the guard was never installed. The stock package does
not provide this experimental 5301 port. Remove only the Goodix menu entries,
helpers, and post-update hook if you installed them. These steps do not edit PAM.

## Source and license

Based on [J0UH/goodix-5201-linux](https://github.com/J0UH/goodix-5201-linux),
commit `1f7f3882026a97ce234c199048b4aee5aeb342e6`, and libfprint. The internal
driver ID remains `goodix5201`; its USB match is `27c6:5301` in this port.
Matching uses the inherited SIGFM/OpenCV implementation. See
[PROVENANCE.md](PROVENANCE.md) for port details and source sanitization.

Licensed under **LGPL-2.1-or-later**, with retained per-file notices and bundled
component licenses. See [LICENSE](LICENSE), source `COPYING`, `AUTHORS`, and
`THANKS`. Packaging and integration scripts added here are also available under
LGPL-2.1-or-later.
