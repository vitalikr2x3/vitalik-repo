#!/usr/bin/env bash
# Build packages from the listed projects, rebuild the pacman database and publish it.
set -euo pipefail

REPO="$HOME/vitalik-repo"
OUT="$REPO/x86_64"
DB="vitalikr2x3.db.tar.gz"

PROJECTS=(
  "$HOME/lyrics-term"
)

mkdir -p "$OUT"

for dir in "${PROJECTS[@]}"; do
  echo "==> Building $(basename "$dir")"
  rm -f "$dir"/*.pkg.tar.zst
  (cd "$dir" && BUILDDIR=/tmp/build-"$(basename "$dir")" makepkg -Cf --noconfirm)
  cp "$dir"/*.pkg.tar.zst "$OUT"/
done

cd "$OUT"
rm -f ./*.old
repo-add -R "$DB" ./*.pkg.tar.zst
cp --remove-destination vitalikr2x3.db.tar.gz vitalikr2x3.db
cp --remove-destination vitalikr2x3.files.tar.gz vitalikr2x3.files
rm -f ./*.old

cd "$REPO"
git add -A
git -c user.name="vitalikr2x3" -c user.email="vitalikr2x3@users.noreply.github.com" commit -m "Update packages $(date +%F)" || echo "No changes"
git push origin main
echo "==> Published: https://vitalikr2x3.github.io/vitalik-repo/x86_64/"
