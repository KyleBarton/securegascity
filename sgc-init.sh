#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/sgc"

# ── Prompt ────────────────────────────────────────────────────────────────────

read -e -r -p "Destination path for your secure Gas City: " CITY_PATH

# Expand ~ if the user typed it, then strip any trailing slashes
CITY_PATH="${CITY_PATH/#\~/$HOME}"
CITY_PATH="${CITY_PATH%/}"

# Derive city name from the final path component
CITY_NAME="$(basename "$CITY_PATH")"

# ── Validate ──────────────────────────────────────────────────────────────────

if [[ ! -d "$CITY_PATH" ]]; then
  echo "error: $CITY_PATH does not exist — run 'gc init' first" >&2
  exit 1
fi

# ── Copy template tree ────────────────────────────────────────────────────────

# cp -r src/. dst/ copies hidden files and directories (e.g. .claude/)
cp -r "$TEMPLATE_DIR/." "$CITY_PATH/"

# ── Fill placeholders in city.toml ───────────────────────────────────────────

# BSD sed (macOS) requires '' after -i; GNU sed accepts it too
for f in "$CITY_PATH/city.toml" "$CITY_PATH/AGENTS.md"; do
  sed -i '' \
    -e "s|__CITY_PATH__|$CITY_PATH|g" \
    -e "s|__CITY_NAME__|$CITY_NAME|g" \
    "$f"
done

# ── Install nono profiles ─────────────────────────────────────────────────────

NONO_PROFILES_DIR="$HOME/.config/nono/profiles"
mkdir -p "$NONO_PROFILES_DIR"

# Template profiles are identified by __CITY_NAME__ in their filename.
# For each one: expand __CITY_NAME__ in the filename, then fill the content.
for src in "$TEMPLATE_DIR/profiles/"*__CITY_NAME__*.json; do
  [[ -e "$src" ]] || continue

  raw_name="$(basename "$src")"
  dest_name="${raw_name//__CITY_NAME__/$CITY_NAME}"
  dest="$NONO_PROFILES_DIR/$dest_name"

  sed -e "s|__CITY_NAME__|$CITY_NAME|g" -e "s|__CITY_PATH__|$CITY_PATH|g" "$src" > "$dest"
  echo "profile installed: $dest"
done

# ── Restart city ─────────────────────────────────────────────────────────────

echo "restarting city at: $CITY_PATH"
(cd "$CITY_PATH" && gc restart)
