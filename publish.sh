#!/usr/bin/env bash
# Собирает пакеты из списка, обновляет базу и отправляет на GitHub Pages
set -euo pipefail

REPO="$HOME/vitalik-repo"
OUT="$REPO/x86_64"
DB="vitalikr2x3.db.tar.gz"

# Папки с PKGBUILD, которые нужно собрать и опубликовать
PROJECTS=(
  "$HOME/lyrics-term"
)

mkdir -p "$OUT"

for dir in "${PROJECTS[@]}"; do
  echo "==> Собираю $(basename "$dir")"
  (cd "$dir" && makepkg -Cf --noconfirm)
  cp "$dir"/*.pkg.tar.zst "$OUT"/
done

cd "$OUT"
repo-add -R "$DB" ./*.pkg.tar.zst

cd "$REPO"
git add -A
git commit -m "Update packages $(date +%F)" || echo "Нет изменений"
git push -u origin main
echo "==> Опубликовано: https://vitalikr2x3.github.io/vitalik-repo/x86_64/"
