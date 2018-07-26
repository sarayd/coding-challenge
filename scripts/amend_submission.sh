#!/bin/bash

source "$(dirname $BASH_SOURCE)/shared.sh"

source "$ROOT/scripts/package_submission.sh"

git checkout $id
git add "$file.enc" "$ROOT/keys/$id.key.enc"
git commit --author "Submission $id <>" -m "Amend submission $id"
git push origin $id
