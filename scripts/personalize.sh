#!/usr/bin/env bash
# Usage (from the project folder):  ./scripts/personalize.sh 1234 jane.doe
# Swaps the 9999 placeholder for your Humber ID digits everywhere
# (file contents AND folder names) and sets your Name tag.
# Uses perl instead of sed -i so it works the same on macOS and Linux.
set -euo pipefail
ID="${1:?give the last 4 digits of your Humber ID}"
NAME="${2:?give firstname.lastname}"
[[ "$ID" =~ ^[0-9]{4}$ ]] || { echo "ID must be exactly 4 digits"; exit 1; }

grep -rl --exclude-dir=.git --exclude-dir=.terraform --exclude=personalize.sh '9999' . \
  | while IFS= read -r f; do perl -pi -e "s/9999/${ID}/g" "$f"; done
perl -pi -e "s/firstname\.lastname/${NAME}/" main.tf scripts/create-backend.sh

for d in modules/*-9999; do
  [ -d "$d" ] && mv "$d" "${d%-9999}-${ID}"
done

here="$(basename "$PWD")"
if [ "$here" = "project-9999" ]; then
  mv "../project-9999" "../project-${ID}"
  echo "Folder renamed to project-${ID} - run: cd ../project-${ID}"
fi
echo "Done. ID=${ID}, Name=${NAME}"
