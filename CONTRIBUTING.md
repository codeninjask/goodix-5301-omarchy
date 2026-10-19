# Contributing

Bug reports, hardware results, and patches are welcome. This port has been
tested on one laptop, so reports from other `27c6:5301` readers are useful.

## Reporting a problem

Include your laptop model, USB ID from `lsusb`, package versions, and what
happened when you ran `fprintd-enroll` or `fprintd-verify`. Add the firmware
identifier if it appears in the daemon's error output.

Paste only the relevant journal lines. Do not attach fingerprint images,
enrollment templates, raw USB captures, or logs containing image bytes.

For a successful hardware report, include which operations you tried:
enrollment, verification, cancellation, reboot, and suspend/resume. Record the
package version and any checks you have not tried yet.

## Building

On Arch Linux, from the repository root:

```sh
sudo pacman -S --needed base-devel
./prepare-source.sh
makepkg --verifysource
makepkg --cleanbuild --syncdeps
```

Build as your normal user. `--syncdeps` installs missing build dependencies
through pacman. To install the resulting package, run `makepkg --install`.

## Testing

Run the menu regressions without a reader:

```sh
python3 tests/test-menu.py
```

After building, run the libfprint tests:

```sh
meson test -C src/build --print-errorlogs
```

Some upstream tests need replay fixtures or fingerprint images omitted from
this repository. See [source notes](docs/source.md). Unit tests cannot establish
that a new reader or firmware works; include hardware results separately.

## Sending a patch

Keep changes focused and explain the problem, the resulting behavior, and how
you checked it. Preserve upstream license and author notices.

If you change vendored source, regenerate the source archive, update its
`b2sums` entry in `PKGBUILD`, regenerate `.SRCINFO` with `makepkg --printsrcinfo`,
and update `SOURCE-MANIFEST.sha256`. See [maintenance](docs/maintenance.md) for
the commands.
