# Goodix 5301 for Arch Linux

A libfprint port for the Goodix `27c6:5301` fingerprint reader, tested on a
Dell Inspiron 5570 running Omarchy. Includes an Arch package and optional
Omarchy menu integration.

Based on [J0UH/goodix-5201-linux](https://github.com/J0UH/goodix-5201-linux).
This is an experimental community driver; it is not maintained by Dell or Goodix.

## Hardware support

| Hardware | Status |
| --- | --- |
| Dell Inspiron 5570, USB `27c6:5301` | Enrollment and verification working |
| Firmware `GF3208_HT_APP_10035` | Tested with package `0.1.0-3` |
| Package `0.1.0-5` | Verification confirmed by the user after the firmware fix |
| Other readers and laptops | Untested |

The driver accepts `GF3208_HT_APP_10035` and `GF5288_HT_APP_10035` only.
It does not flash firmware. See the [test notes](docs/hardware.md) for results
and remaining checks.

## Install

On x86_64 Arch Linux or Omarchy, run as your normal user:

```sh
sudo pacman -S --needed git
git clone https://github.com/codeninjask/goodix-5301-omarchy.git
cd goodix-5301-omarchy
./install.sh
```

The installer checks for the reader, builds the bundled source with `makepkg`,
and installs the driver and `fprintd`. Accept the replacement of `libfprint` or
`libfprint-git` when pacman asks. This package replaces the system libfprint library.

The installer leaves PAM and login settings alone. Keep password authentication
available if you configure fingerprint authentication later.

## Enroll a finger

```sh
fprintd-enroll
fprintd-verify
```

Press and hold briefly, lift, and change placement slightly between samples.
Enrollment takes 15 samples; retries do not count toward that total. Look for
`enroll-completed`, then `verify-match`.

To list saved fingers:

```sh
fprintd-list "$USER"
```

## Omarchy

The optional menu adds enrollment, verification, saved-finger removal, and
reader checks under **Setup → Security → Fingerprint**.
See [Omarchy setup](docs/omarchy.md) for installation and update protection.

Omarchy's stock fingerprint setup command may replace this package with
`libfprint-git`. Use the custom menu or the `fprintd-*` commands with this driver.

## Troubleshooting

Start with:

```sh
lsusb -d 27c6:5301
pacman -Q libfprint-goodix-5301 fprintd
journalctl -b -u fprintd.service --no-pager
```

- **Unsupported firmware:** check that `0.1.0-5` or newer is installed. If the
  reported identifier differs from both listed above, include it in an issue.
- **Device already claimed:** close other enrollment, verification, or
  authentication prompts before retrying. Only one client can use the reader.
- **Reader stops responding:** try a reboot and include the relevant daemon
  errors in your report.

For other problems, [open an issue](https://github.com/codeninjask/goodix-5301-omarchy/issues/new/choose)
with your laptop model, USB ID, package versions, and the steps that failed.
Review logs before posting; leave out fingerprint images, saved templates,
and USB captures.

## Uninstall

If you installed the optional package replacement guard, disable it first:

```sh
sudo mv /etc/pacman.d/hooks/05-goodix5301-preserve-driver.hook \
  /etc/pacman.d/hooks/05-goodix5301-preserve-driver.hook.disabled
```

Restore Arch's standard library:

```sh
sudo pacman -S libfprint
```

The standard package does not include this 5301 port. If you installed the
Omarchy integration, remove its menu entries, helpers, and update hook too.

## Development

Build instructions and reporting guidelines are in [CONTRIBUTING.md](CONTRIBUTING.md).
The [source notes](docs/source.md) cover the upstream revision, port changes,
and omitted test fixtures.

## License

[LGPL-2.1-or-later](LICENSE). Upstream authorship notices and bundled component
licenses are retained in the source tree. Packaging and integration scripts
use the same license.
