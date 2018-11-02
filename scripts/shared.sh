#!/bin/bash
set -Eeuo pipefail

ROOT=$(dirname $(dirname $BASH_SOURCE))

BOLD=$(tput bold)
NORMAL=$(tput sgr0)

function say() {
  echo "${BOLD}$1${NORMAL}"
}

function ensure_key() {
  if [ ! -f "$ROOT/keys/$1.key.unencrypted" ]; then
    openssl rand -base64 32 > "$ROOT/keys/$1.key.unencrypted"
    openssl rsautl -encrypt -inkey "$ROOT/keys/public.pem" -pubin -in "$ROOT/keys/$1.key.unencrypted" -out "$ROOT/keys/$1.key.enc"
  fi
}

function encrypt_file() {
  ensure_key $1
  openssl aes-256-cbc -md ${3:-sha256} -salt -a -e -in $2 -out $2.enc -pass file:"$ROOT/keys/$1.key.unencrypted"
}

function decrypt_file() {
  openssl rsautl -decrypt -inkey "$ROOT/keys/private.pem" -passin file:"$ROOT/keys/.password" -in "$ROOT/keys/$1.key.enc" -out "$ROOT/keys/$1.key.unencrypted"
  openssl aes-256-cbc -md ${3:-sha256} -salt -a -d -in $2.enc -out $2 -pass file:"$ROOT/keys/$1.key.unencrypted"
}

function submission_dir() {
  echo "$ROOT/submissions/$1.unencrypted"
}

function tar_file() {
  echo "$ROOT/submissions/$1.tar.gz"
}
