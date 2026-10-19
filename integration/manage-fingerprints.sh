#!/usr/bin/env bash
# Native Omarchy menu actions for the installed Goodix 5301 driver.
set -euo pipefail

fingerprint_user=$(id -un)
finger_names=(
  'Right Index Finger' 'Right Thumb' 'Right Middle Finger' 'Right Ring Finger'
  'Right Little Finger' 'Left Index Finger' 'Left Thumb' 'Left Middle Finger'
  'Left Ring Finger' 'Left Little Finger'
)
finger_ids=(
  right-index-finger right-thumb right-middle-finger right-ring-finger
  right-little-finger left-index-finger left-thumb left-middle-finger
  left-ring-finger left-little-finger
)

if [[ ${1:-} == --check ]]; then
  pacman -Q libfprint-goodix-5301 >/dev/null
  omarchy-hw-fingerprint
  pacman -T libfprint-git fprintd usbutils
  exit
fi

launch_task() {
  local command
  printf -v command '%q ' "$HOME/.local/bin/goodix5301-settings" "$@"
  omarchy-launch-floating-terminal-with-presentation "$command"
}

# Keep one menu enrollment/verification/deletion active at a time. fprintd
# still arbitrates claims from PAM and other clients.
case ${1:-menu} in
  enroll|verify-run|delete-run)
    : "${XDG_RUNTIME_DIR:?No desktop runtime directory available}"
    exec 9>"$XDG_RUNTIME_DIR/goodix5301-operation.lock"
    if ! flock -n 9; then
      printf 'Another fingerprint operation is running. Close it and try again.\n' >&2
      exit 1
    fi
    ;;
esac

# Some fprintd clients return success even when the reported scan fails.
# Require the completion event as well as a successful process exit.
run_checked() {
  local expected=$1 output result=0
  shift
  output=$(mktemp)
  trap 'rm -f -- "$output"' EXIT
  LC_ALL=C "$@" | tee "$output" || result=$?
  if (( result )) || ! grep -Eq -- "$expected" "$output"; then
    printf '\nFingerprint operation failed or was cancelled. See the result above.\n' >&2
    rm -f -- "$output"
    trap - EXIT
    return 1
  fi
  rm -f -- "$output"
  trap - EXIT
}

case ${1:-menu} in
  menu) exec omarchy menu summon setup.security.fingerprint ;;
  add)
    finger=$(omarchy menu select 'Add Fingerprint' "${finger_names[@]}") || exit 0
    for i in "${!finger_names[@]}"; do
      if [[ $finger == "${finger_names[$i]}" ]]; then
        finger=${finger_ids[$i]}
        output=$(LC_ALL=C fprintd-list "$fingerprint_user") || { launch_task list-run; exit 1; }
        if grep -Eq -- ": $finger$" <<<"$output"; then
          answer=$(omarchy menu select 'Replace Saved Fingerprint?' 'Cancel' 'Replace') || exit 0
          [[ $answer == Replace ]] || exit 0
        fi
        launch_task enroll "$finger"
        exit
      fi
    done
    exit 1
    ;;
  enroll)
    finger=${2:?Missing finger}
    valid=false
    for candidate in "${finger_ids[@]}"; do
      [[ $candidate != "$finger" ]] || valid=true
    done
    "$valid" || exit 1
    pacman -Q libfprint-goodix-5301 >/dev/null
    printf 'Touch, hold briefly, then lift. Vary placement for each sample.\n\n'
    if run_checked "Enroll result: enroll-completed$" fprintd-enroll -f "$finger" "$fingerprint_user"; then
      printf '\nLift your finger, then touch again to verify.\n'
      run_checked "Verify result: verify-match \(done\)$" fprintd-verify -f "$finger" "$fingerprint_user"
    else
      exit 1
    fi
    ;;
  verify) launch_task verify-run ;;
  verify-run) run_checked "Verify result: verify-match \(done\)$" fprintd-verify "$fingerprint_user" ;;
  delete)
    output=$(LC_ALL=C fprintd-list "$fingerprint_user") || { launch_task list-run; exit; }
    rows=()
    for i in "${!finger_ids[@]}"; do
      if grep -Eq -- ": ${finger_ids[$i]}$" <<<"$output"; then
        rows+=("${finger_names[$i]}")
      fi
    done
    if (( ! ${#rows[@]} )); then
      omarchy menu select 'Remove Saved Fingerprint' 'No Fingerprints Enrolled' >/dev/null || true
      exit
    fi
    finger=$(omarchy menu select 'Remove Saved Fingerprint' "${rows[@]}") || exit 0
    for i in "${!finger_names[@]}"; do
      if [[ $finger == "${finger_names[$i]}" ]]; then
        answer=$(omarchy menu select "Delete $finger?" 'Cancel' 'Delete Saved Fingerprint') || exit 0
        [[ $answer == 'Delete Saved Fingerprint' ]] || exit 0
        launch_task delete-run "${finger_ids[$i]}"
        exit
      fi
    done
    exit 1
    ;;
  delete-run)
    exec python "$HOME/.local/libexec/goodix5301/delete-fingerprint.py" "${2:?Missing finger}"
    ;;
  list)
    output=$(LC_ALL=C fprintd-list "$fingerprint_user") || { launch_task list-run; exit; }
    rows=()
    for i in "${!finger_ids[@]}"; do
      if grep -Eq -- ": ${finger_ids[$i]}$" <<<"$output"; then
        rows+=("${finger_names[$i]}")
      fi
    done
    (( ${#rows[@]} )) || rows=('No Fingerprints Enrolled')
    omarchy menu select 'Enrolled Fingers' "${rows[@]}" >/dev/null || true
    ;;
  list-run) exec fprintd-list "$fingerprint_user" ;;
  status) launch_task status-run ;;
  status-run) exec "$HOME/.local/libexec/goodix5301/check-reader.sh" ;;
  *) printf 'Unknown fingerprint action: %s\n' "$1" >&2; exit 2 ;;
esac
