# Hardware tests

Results from a Dell Inspiron 5570 running Omarchy on Arch Linux.

| Component | Value |
| --- | --- |
| USB reader | `27c6:5301` |
| Sensor model | `0x2202` |
| Transport | CDC ACM bridge, bulk OUT `0x03`, IN `0x81` |
| Image geometry | 108 × 88, 12-bit |

## 2026-10-19 — package 0.1.0-5

The reader reported `GF5288_HT_APP_10035` after previously reporting
`GF3208_HT_APP_10035`. Package `0.1.0-3` rejected the new identifier during
enrollment and verification. The reason for the identifier change is unknown.

Package `0.1.0-5` accepts both exact identifiers. After installing it, the user
reported that verification worked. The firmware identifier was not captured
during that successful scan, so this result does not independently confirm
which identifier the reader returned.

Fresh enrollment, cancellation and retry, reboot, and suspend/resume still
need results recorded for this package.

Automated checks for the repair:

- Full local source suite: 6 passed, 0 failed, 36 skipped.
- Repository source suite: 5 passed, 0 failed, 1 skipped (omitted image fixture).
- Menu regressions: 7 passed.

## 2026-10-18 — packages 0.1.0-2 and 0.1.0-3

Firmware: `GF3208_HT_APP_10035`.

- Activation, reset, volatile sensor configuration, and background calibration
  completed.
- Enrollment completed all 15 samples; verification returned `verify-match`.
- Package `0.1.0-3` matched the existing enrollment through the standard fprintd
  service after the SIGFM equality/reporting fixes, without the earlier warnings.
- Sleep, deactivation, and close completed; USB interfaces returned to `cdc_acm`.
  This records driver shutdown, not a laptop suspend/resume test.
- Separately configured sudo and Omarchy lock-screen authentication worked.
  The repository installer does not configure those PAM settings.

Package `0.1.0-4` repackaged the same runtime source for publication. Release
and debug packages built, but that revision had no separate hardware test.

## Coverage

These are results from one reader, not measurements of false-accept or
false-reject rates. Other laptops and readers remain untested. Hardware reports
should include the package version, firmware identifier when available, and
which operations were tried. Keep biometric data out of reports.
