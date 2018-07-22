#!/bin/bash

ROOT=$(dirname $(dirname $BASH_SOURCE))

BOLD=$(tput bold)
NORMAL=$(tput sgr0)

function say() {
  echo "${BOLD}$1${NORMAL}"
}

function encrypt_file() {
  openssl aes-256-cbc -salt -a -e -in $1 -out $1.enc -pass env:ENC_PASSWORD
}

function submission_dir() {
  echo "$ROOT/submissions/$1.unencrypted"
}

function tar_file() {
  echo "$ROOT/submissions/$1.tar.gz"
}
