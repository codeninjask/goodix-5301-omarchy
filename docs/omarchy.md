# Omarchy integration

Install the driver first using the instructions in the [README](../README.md).
These helpers add a fingerprint menu and optional update checks. They do not
configure PAM or screen unlocking.

## Menu

From the repository root:

```sh
install -Dm755 integration/manage-fingerprints.sh "$HOME/.local/bin/goodix5301-settings"
install -Dm755 integration/check-reader.sh "$HOME/.local/libexec/goodix5301/check-reader.sh"
install -Dm755 integration/delete-fingerprint.py "$HOME/.local/libexec/goodix5301/delete-fingerprint.py"
```

Merge [integration/omarchy-menu.json](../integration/omarchy-menu.json) into
`~/.config/omarchy/extensions/omarchy-menu.jsonc`. Preserve any existing entries.
If you do not already have that file, copy the template:

```sh
mkdir -p "$HOME/.config/omarchy/extensions"
cp -n integration/omarchy-menu.json "$HOME/.config/omarchy/extensions/omarchy-menu.jsonc"
```

Open **Setup → Security → Fingerprint**. The menu can add, verify, list, and
remove saved fingers, or check the reader. Enrollment, verification, and deletion
share a lock to prevent overlapping menu operations. Other authentication clients
can still claim the reader.

These helpers use Omarchy's user extension points. Changes to Omarchy's menu
API may require updates here.

## Update checks

After installing the menu helpers, add a post-update health notification:

```sh
omarchy hook install post-update integration/goodix5301-health.hook
```

It checks the package, library dependencies, reader detection, and menu helpers.
You can run the same check from **Fingerprint → Check Reader**.

To block pacman transactions that would replace this driver with `libfprint`
or `libfprint-git`:

```sh
sudo install -Dm755 integration/protect-driver.sh /usr/local/libexec/goodix5301-protect-driver
sudo install -Dm644 integration/05-goodix5301-preserve-driver.hook /etc/pacman.d/hooks/05-goodix5301-preserve-driver.hook
```

The guard aborts those transactions before packages change. Review a blocked
update before proceeding. Library ABI changes may still require a rebuild.

## Removal

Remove the entries you merged into `omarchy-menu.jsonc`, the three installed
helpers, and the `goodix5301-health` post-update hook if installed. Remove the
pacman guard and `/usr/local/libexec/goodix5301-protect-driver` if installed.
See [Uninstall](../README.md#uninstall) to restore the standard library.
