#!/bin/bash

source "$(dirname $BASH_SOURCE)/shared.sh"

username=$(cat "$ROOT/.username")
dir=$(submission_dir "$username")

if [ -f "$ROOT/.id" ]; then
  id=$(cat "$ROOT/.id")
  say "Your Submission ID is $id"
else
  id=$(uuidgen)
  say "Your Submission ID is $id"
  echo $id > "$ROOT/.id"
fi

file=$(tar_file $id)

rm -f $file $file.enc
tar -zcf $file $dir
encrypt_file $id $file
rm $file
