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

sudo dnf autoremove --assumeyes
sudo dnf check-update --assumeyes
sudo dnf upgrade --assumeyes
sudo dnf clean all --assumeyes

if ! dnf list installed bash-completion >/dev/null 2>&1; then
  sudo dnf install bash-completion --assumeyes
fi
if ! command -v command-not-found >/dev/null 2>&1; then
  sudo dnf install command-not-found --assumeyes
fi
if ! command -v info >/dev/null 2>&1; then
  sudo dnf install info --assumeyes
fi
if ! command -v man >/dev/null 2>&1; then
  sudo dnf install man-db --assumeyes
fi
if ! command -v git >/dev/null 2>&1; then
  sudo dnf install git --assumeyes
fi
