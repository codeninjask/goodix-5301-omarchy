# Hardware validation

Recorded on 2026-10-18 on a Dell Inspiron 5570 running Omarchy/Arch Linux.
This is a summary of observed results, not raw device logs or biometric data.

| Property | Tested value |
| --- | --- |
| USB reader | `27c6:5301` |
| Firmware reported by reader | `GF3208_HT_APP_10035` |
| Sensor model | `0x2202` |
| Transport | CDC ACM bridge; bulk OUT `0x03`, IN `0x81` |
| Image geometry | 108 × 88, 12-bit |
| Successful hardware package | `libfprint-goodix-5301 0.1.0-3` |

Observed results:

- Activation, reset, volatile sensor configuration, and background calibration
  completed successfully. No firmware flashing was used.
- Enrollment completed all 15 samples. Verification returned `verify-match`.
- After the SIGFM equality/reporting fixes, the standard fprintd service matched
  an existing enrollment without the previous assertion/gallery warnings.
- Sleep, deactivation, and close succeeded; USB interfaces returned to `cdc_acm`.
- The prior available test suite reported 5 passed, 0 failed, and 36 skipped
  because emulation was unavailable. The SIGFM equality regression uses
  synthetic descriptors, not recorded fingerprint images.
- Separately configured sudo and Omarchy lock-screen fingerprint authentication
  worked on the original laptop. This repository's installer does not enable
  those PAM settings.

Package revision `0.1.0-4` repackages the same runtime source for publication.
The hardware driver, matcher, SIGFM equality/reporting fixes, and synthetic
regression test are preserved. Both release and debug packages built locally.
The sanitized suite passed 4 tests with 0 failures and 1 explicitly skipped
image-dependent assembly test. The device suite includes the synthetic SIGFM
equality regression. The new package has not been installed for a new hardware
test during publication.

Testing on one reader does not establish false-accept/reject rates or production
security. Compatibility with other firmware, laptops, or future library versions
is unproven. Password fallback should remain available.
