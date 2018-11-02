#!/bin/bash

source "$(dirname $BASH_SOURCE)/shared.sh"

function unpackage_shared() {
  parent=$(dirname $1)
  file=$(basename $1 .enc)
  id=$(basename $1 $2)

  decrypt_file $id "$parent/$file" ${3:-}
  tar -xzf "$parent/$file"
}

function unpackage_legacy() {
  unpackage_shared $1 .tar.gz.legacy.enc md5
}

function unpackage() {
  unpackage_shared $1 .tar.gz.enc
}

for file in $ROOT/submissions/*.tar.gz.legacy.enc; do
  [ -e "$file" ] || continue
  unpackage_legacy $file
done

for file in $ROOT/submissions/*.tar.gz.enc; do
  [ -e "$file" ] || continue
  unpackage $file
done
