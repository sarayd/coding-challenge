#!/bin/bash

source "$(dirname $BASH_SOURCE)/shared.sh"

function unpackage() {
  parent=$(dirname $1)
  file=$(basename $1 .enc)
  id=$(basename $1 .tar.gz.enc)

  decrypt_file $id "$parent/$file"
  tar -xzf "$parent/$file"
}

for file in $ROOT/submissions/*.tar.gz.enc; do
  unpackage $file
done
