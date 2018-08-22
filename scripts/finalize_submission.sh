#!/bin/bash

source "$(dirname $BASH_SOURCE)/shared.sh"

source "$ROOT/scripts/package_submission.sh"

git checkout -b $id
git add "$file.enc" "$ROOT/keys/$id.key.enc"
git commit --author "$git_author" -m "Add submission $id"
git push origin $id
