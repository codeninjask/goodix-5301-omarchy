#!/usr/bin/env bash
# ALPM pre-transaction guard: retain this machine's experimental driver.
set -euo pipefail
if /usr/bin/pacman -Qq libfprint-goodix-5301 >/dev/null 2>&1; then
  printf '%s\n' \
    'Goodix 5301: this transaction would install a different libfprint driver.' \
    'The experimental 27c6:5301 driver is required on this laptop.' \
    'Review the replacement before proceeding. For an intentional rollback,' \
    'temporarily move /etc/pacman.d/hooks/05-goodix5301-preserve-driver.hook aside.' >&2
  exit 1
fi
