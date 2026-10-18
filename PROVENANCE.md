# Source provenance

The vendored source lives in `source/libfprint-goodix-5301-0.1.0/`. It derives
from the J0UH/goodix-5201-linux libfprint branch at commit
`1f7f3882026a97ce234c199048b4aee5aeb342e6`.

The working local port includes:

- USB matching for `27c6:5301`, retaining the internal `goodix5201` identifier.
- Exact firmware allowlisting for the observed `GF3208_HT_APP_10035` string.
  Earlier notes named `GF5288_HT_APP_10035`; that did not match this reader.
- Waiting for the delayed reset response before the next configuration command.
- The existing 256-byte type-08 sensor configuration, sent to volatile RAM.
  It was checked against Dell's signed Goodix Windows driver 1.0.33.800 and
  matched the community type-08 configuration byte for byte. No Dell Windows
  executable, library, installer, or firmware binary is included.
- SIGFM print equality using serialized synthetic/sample descriptors and
  host-scan report handling for verification/identification. These changes do
  not alter the matching algorithm, threshold, or saved template format.
- A synthetic SIGFM equality regression in `tests/test-fpi-device.c` covering
  empty, copied, differing, deserialized, and metadata-independent samples.
- The corrected autosuspend comment needed by the generated-hwdb check.

For publication, upstream example fingerprint images, hardware replay fixtures
(including text USB traces), the embedded SIGFM image fixture and its standalone test, and the demo PNG
were removed. Tests requiring
those fixtures are disabled in `tests/meson.build`; the image-dependent C
assembly test is explicitly skipped. The other C unit tests, including the SIGFM
regression, remain. AppStream metadata validation runs offline. The optional GTK demo and installed replay tests are
not supported by this sanitized snapshot; the PKGBUILD disables both. The
documentation build is also disabled by the package, as in the working build.
Upstream CI configuration was omitted because it targets the original tree.

All retained runtime source files are unchanged from the working local source.
The only modified vendored files are `tests/meson.build` and
`libfprint/sigfm/meson.build` (test selection and offline validation). Licensing and authorship
notices are retained. `SOURCE-MANIFEST.sha256` records the published source files.

The source archive is generated locally with fixed timestamps, ownership, order,
and permissions. Its BLAKE2 checksum is pinned in PKGBUILD. When deliberately
editing source, regenerate the archive and update both the checksum and source
manifest before building or publishing.
