#!/usr/bin/env bash
# Produce the same local source archive from every clean checkout.
set -euo pipefail
cd -- "$(dirname -- "$0")"
archive=libfprint-goodix-5301-0.1.0.tar.gz
temporary=$(mktemp "./${archive}.XXXXXX")
trap 'rm -f -- "$temporary"' EXIT
LC_ALL=C tar --sort=name --mtime=@0 --owner=0 --group=0 --numeric-owner \
  --format=gnu --mode='u+rwX,go+rX,go-w' \
  -C source -cf - libfprint-goodix-5301-0.1.0 | gzip -n > "$temporary"
mv -- "$temporary" "$archive"
printf 'Prepared %s from the bundled source.\n' "$archive"
