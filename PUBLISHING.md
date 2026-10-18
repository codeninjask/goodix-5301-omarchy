# Publication contents and exclusions

This repository contains source code, source licensing/attribution, the Arch
PKGBUILD and USB rule, build/install scripts, documentation, and optional Omarchy
menu/update helpers. `PUBLISH-FILES.txt` lists every file selected for publication.
`SOURCE-MANIFEST.sha256` records the vendored source checksums.

The original driver workspace and its private diagnostics are outside this Git
repository. It starts with fresh Git history and has no upstream community
repository configured as a remote. The intended public destination is
`codeninjask/goodix-5301-omarchy`, with branch `main`.

Excluded from the initial publication:

- All fingerprint images, including the upstream image embedded in a C++ array,
  enrollment templates, and saved biometric data.
- All USB captures/replay fixtures, private logs, and local session history.
- Dell Windows binaries, installers, driver packages, and extracted DLLs.
- Built Linux libraries, package/debug archives, build directories, and caches.
- Machine-specific debug notes, authentication backups, and PAM configuration.
- Local credentials, account configuration, and Codex workspace metadata.

Public source includes the sensor's type-08 configuration byte array inherited
from the community implementation; it is runtime source, not a fingerprint
sample or a bundled Windows driver binary. Synthetic unit-test descriptors are
programmatically generated and contain no captured fingerprint data.

The tracked files are text. `.gitignore` also excludes common captures, image
formats, binary packages, and private metadata. Review new staged changes before
every later publication; ignore rules alone cannot establish privacy.

The installer and optional helpers do not change PAM/login settings. Existing
authentication and enrolled prints on the original machine are left untouched.

To finish publication from an authenticated, network-connected terminal, run
`./publish.sh`. It requires the `codeninjask` GitHub account, a clean committed
`main` branch, and the exact intended HTTPS remote. It creates a public repository
if no remote exists, checks destination ownership and visibility, and then pushes.
It never configures the upstream community repository as a remote.
