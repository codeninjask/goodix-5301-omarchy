# Source notes

The bundled tree at `source/libfprint-goodix-5301-0.1.0/` is based on
[J0UH/goodix-5201-linux](https://github.com/J0UH/goodix-5201-linux) at commit
`1f7f3882026a97ce234c199048b4aee5aeb342e6`.

## Port changes

- Match USB `27c6:5301`. The internal driver name remains `goodix5201`.
- Accept the exact firmware identifiers `GF3208_HT_APP_10035` and
  `GF5288_HT_APP_10035`, allowing trailing NUL padding.
- Wait for the delayed reset response before sending the next configuration
  command.
- Reject empty continuation packets and short USB writes.
- Compare SIGFM prints through serialized sample descriptors and handle
  host scans correctly in verification/identification reports. The matcher,
  threshold, and stored template format are unchanged.
- Add synthetic SIGFM equality and firmware identifier regressions.
- Correct the autosuspend comment checked by the generated-hwdb test.

Matching uses the inherited SIGFM/OpenCV implementation.

## Sensor configuration

The driver sends the inherited 256-byte type-08 configuration to volatile RAM.
It was compared with Dell's signed Goodix Windows driver 1.0.33.800 and matched
byte for byte. No Dell executable, installer, DLL, or firmware binary is bundled.

## Omitted fixtures

Upstream fingerprint images, USB replay fixtures (including text traces), the
embedded SIGFM image fixture and its standalone test, and the demo PNG are
omitted. Synthetic descriptors used in unit tests contain no captured
fingerprint data.

`tests/meson.build` and `libfprint/sigfm/meson.build` adjust test selection for
this tree. The image-dependent assembly test is skipped; other C unit tests
remain. AppStream validation runs offline. The PKGBUILD disables the GTK demo,
installed replay tests, and documentation build. Upstream CI configuration was
omitted because it targets the original tree.

Runtime source matches the local working port. Upstream license and author
notices are retained. `SOURCE-MANIFEST.sha256` in the repository root records
the vendored files; [maintenance.md](maintenance.md) describes how to update it.
