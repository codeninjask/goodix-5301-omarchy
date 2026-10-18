#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")"

if (( EUID == 0 )); then
  echo 'Run as your normal user; sudo is used for package installation.' >&2
  exit 1
fi
for command_name in pacman sudo; do
  command -v "$command_name" >/dev/null || {
    printf 'Required command not found: %s\n' "$command_name" >&2
    exit 1
  }
done

sudo pacman -S --needed base-devel usbutils
if ! lsusb -d 27c6:5301 >/dev/null 2>&1; then
  echo 'Goodix USB reader 27c6:5301 is not visible; stopping before driver installation.' >&2
  exit 1
fi

./prepare-source.sh
makepkg --cleanbuild --syncdeps --install
sudo pacman -S --needed fprintd
sudo systemctl try-restart fprintd.service

printf '\nDriver installed. Enroll and verify as your normal user:\n'
printf '  fprintd-enroll\n  fprintd-verify\n'
printf '\nSee README.md for optional Omarchy menu and update protection setup.\n'
printf 'PAM and login settings have not been changed.\n'
