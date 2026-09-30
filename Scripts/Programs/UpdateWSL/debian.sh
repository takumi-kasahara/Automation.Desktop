#!/usr/bin/env bash
[[ -n "${TRACE:-}" ]] && set -o xtrace
set -o errexit
set -o errtrace
set -o functrace
set -o noclobber
set -o nounset
set -o pipefail
shopt -s failglob
shopt -s huponexit
shopt -s inherit_errexit
shopt -s lastpipe
shopt -s nullglob
shopt -s shift_verbose

sudo apt autoremove --yes
sudo apt update --yes
sudo apt upgrade --yes
sudo apt clean --yes

if ! dpkg -s bash-completion >/dev/null 2>&1; then
  sudo apt install bash-completion --yes
fi
if ! command -v command-not-found >/dev/null 2>&1; then
  sudo apt install command-not-found --yes
fi
if ! command -v info >/dev/null 2>&1; then
  sudo apt install info --yes
fi
if ! command -v man >/dev/null 2>&1; then
  sudo apt install man-db --yes
fi
if ! command -v git >/dev/null 2>&1; then
  sudo apt install git --yes
fi
