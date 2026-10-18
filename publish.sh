#!/usr/bin/env bash
# Publish only to this port's new repository, never to the community upstream.
set -euo pipefail
cd -- "$(dirname -- "$0")"
repository=codeninjask/goodix-5301-omarchy
expected_url="https://github.com/${repository}.git"

[[ $(git branch --show-current) == main ]] || {
  echo 'Expected the completed main branch.' >&2; exit 1;
}
[[ -z $(git status --porcelain) ]] || {
  echo 'Commit or review pending files before publishing.' >&2; exit 1;
}
account=$(gh api user --jq .login)
[[ $account == codeninjask ]] || {
  echo 'Expected the authenticated GitHub account codeninjask.' >&2; exit 1;
}

if ! git remote get-url origin >/dev/null 2>&1; then
  [[ -z $(git remote) ]] || {
    echo 'Unexpected remotes configured; review them before publishing.' >&2; exit 1;
  }
  gh repo create "$repository" --public \
    --description 'Experimental hardware-tested Goodix 27c6:5301 libfprint driver for Dell Inspiron 5570 on Arch/Omarchy'
  git remote add origin "$expected_url"
fi

[[ $(git remote get-url origin) == "$expected_url" &&
   $(git remote get-url --push origin) == "$expected_url" ]] || {
  echo 'Origin does not point exclusively to the intended repository.' >&2; exit 1;
}
[[ $(gh repo view "$repository" --json nameWithOwner --jq .nameWithOwner) == "$repository" ]]
[[ $(gh repo view "$repository" --json visibility --jq .visibility) == PUBLIC ]] || {
  echo 'The destination repository must be public.' >&2; exit 1;
}
git push --set-upstream origin main
printf 'Published https://github.com/%s\n' "$repository"
