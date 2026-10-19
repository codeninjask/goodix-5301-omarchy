---
name: Bug report
about: Report an installation, reader, or menu problem
---

## What happened?

Describe what you tried, what you expected, and what happened instead.

## System

- Laptop model:
- Distribution:
- USB ID (`lsusb -d 27c6:5301`):
- Package versions (`pacman -Q libfprint-goodix-5301 fprintd`):
- Firmware identifier, if shown in the journal:

## Steps to reproduce

1.
2.

## Relevant output

Paste the relevant errors from `journalctl -b -u fprintd.service` here.
Review them first. Do not upload fingerprint images, templates, raw USB
captures, or logs containing image bytes.
