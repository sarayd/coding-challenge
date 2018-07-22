#!/bin/bash

source "$(dirname $BASH_SOURCE)/shared.sh"

./package_submission.sh

git checkout $id
git add "$file.enc"
git commit --author "Submission $id <>" -m "Amend submission $id"
git push origin $id
