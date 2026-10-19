#!/usr/bin/env bash
# Read-only update check; does not open the sensor or alter authentication.
set -uo pipefail
problems=0
report() { printf 'ATTENTION: %s\n' "$*" >&2; problems=$((problems + 1)); }

if pacman -Q libfprint-goodix-5301; then
  version=$(pacman -Q libfprint-goodix-5301)
  if (( $(vercmp "${version##* }" 0.1.0-5) < 0 )); then
    report 'Installed driver predates the dual-firmware repair; install version 0.1.0-5 or newer.'
  fi
  library=/usr/lib/libfprint-2.so.2.0.0
  if [[ -r $library ]]; then
    link_report=$(ldd -r "$library" 2>&1)
    if [[ $? != 0 ]] || grep -Eq 'not found|undefined symbol' <<<"$link_report"; then
      report 'Library dependencies changed; rebuild the driver before using fingerprints.'
      printf '%s\n' "$link_report" >&2
    fi
  else
    report 'The installed libfprint library is missing.'
  fi
else
  report 'The Goodix 5301 package is missing or was replaced.'
fi
pacman -Q fprintd >/dev/null 2>&1 || report 'fprintd is missing.'
omarchy-hw-fingerprint || report 'The fingerprint reader is not detected.'
for helper in omarchy-menu-select omarchy-launch-floating-terminal-with-presentation; do
  command -v "$helper" >/dev/null || report "Omarchy helper changed: $helper"
done
[[ -x $HOME/.local/bin/goodix5301-settings ]] || report 'Fingerprint menu helper is missing.'
grep -q 'goodix5301-settings' "$HOME/.config/omarchy/extensions/omarchy-menu.jsonc" ||
  report 'The user fingerprint menu extension is missing.'

if [[ -f /etc/pam.d/omarchy-lock-fingerprint ]]; then
  printf 'Fingerprint unlocking is configured.\n'
else
  printf 'Fingerprint unlocking is not enabled; password locking is unchanged.\n'
fi
if (( problems )); then
  printf 'Driver workspace: %s/goodix-5301-omarchy\n' "$HOME" >&2
  exit 1
fi
printf 'Driver linkage, reader detection, and menu helpers are healthy.\n'
printf 'This check does not measure matching accuracy or guarantee future ABI compatibility.\n'
