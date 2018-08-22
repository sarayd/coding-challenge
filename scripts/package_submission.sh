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

git_name="Submission $(cut -d '-' -f1 <<< $id)"
git_email="$id@coding-challenge.meetkaruna.com"
git_author="$git_name <$git_email>"

git config user.name $git_name
git config user.email $git_email

file=$(tar_file $id)

rm -f $file $file.enc
tar -zcf $file $dir
encrypt_file $id $file
rm $file
