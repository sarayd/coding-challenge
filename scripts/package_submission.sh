#!/bin/bash

source "$(dirname $BASH_SOURCE)/shared.sh"

username=$(cat "$ROOT/.username")
dir=$(submission_dir "$username")
id=$(uuidgen)
file=$(tar_file $id)

echo $username > "$ROOT/.id"

rm $file $file.enc
tar -zcf $file $dir
encrypt_file $file
