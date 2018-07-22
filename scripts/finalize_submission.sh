#!/bin/bash

source "$(dirname $BASH_SOURCE)/shared.sh"

source "$ROOT/scripts/package_submission.sh"

git checkout -b $id
git add "$file.enc"
git commit --author "Submission $id <>" -m "Add submission $id"
git push origin $id
