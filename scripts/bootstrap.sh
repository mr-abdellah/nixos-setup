#!/usr/bin/env bash
#
# Bootstrap a NixOS host for THIS machine into ~/nixos.
# username + hostname are taken from the current user / hostname.
# Prompts for a login password and passes its hash to copier.
#
# Usage: ./scripts/bootstrap.sh [DEST]   (DEST defaults to ~/nixos)
#
set -euo pipefail

DEST="${1:-$HOME/nixos}"
SRC="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

# Prompt for the login password (hidden) and confirm it.
read -rs -p "Login password for $(id -un): " pw; echo
read -rs -p "Confirm password: " pw2; echo
[ "$pw" = "$pw2" ] || { echo "passwords do not match" >&2; exit 1; }
[ -n "$pw" ] || { echo "password must not be empty" >&2; exit 1; }

# Hash it (SHA-512 crypt); mkpasswd ships with nixpkgs.
hash="$(printf '%s' "$pw" | nix --extra-experimental-features 'nix-command flakes' run nixpkgs#mkpasswd -- -m sha-512 -s)"
unset pw pw2

exec nix-shell -p copier --run "copier copy --trust --defaults \
  --data username=\"$(id -un)\" \
  --data hostname=\"$(hostname)\" \
  --data user_password_hash=\"$hash\" \
  \"$SRC\" \"$DEST\""
