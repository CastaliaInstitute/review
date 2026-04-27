#!/usr/bin/env bash
# Add a book to bibliotech: archive to the private local store, convert MOBI/AZW* to
# EPUB if needed, then run `npm run upload:local-epub` in ../bibliotech.
# Requires Calibre's `ebook-convert` for non-EPUB inputs: https://calibre-ebook.com
#
# Usage:
#   ./scripts/add-epub-to-bibliotech.sh <path-to.epub|.mobi|.azw3> [-- npm args...]
#   REVIEW_PRIVATE_BOOKS_DIR=private/books ./scripts/add-epub-to-bibliotech.sh book.mobi -- --review
#
# Set BIBLIOTECH_ROOT to override ../bibliotech. Set REVIEW_PRIVATE_BOOKS_DIR to override
# the default (sibling dir ../.castalia-review-private-books).

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BIB="${BIBLIOTECH_ROOT:-"$ROOT/../bibliotech"}"
BIB="$(cd "$BIB" 2>/dev/null && pwd || true)"
STORE="${REVIEW_PRIVATE_BOOKS_DIR:-"$ROOT/../.castalia-review-private-books"}"
STORE="$(mkdir -p "$STORE" 2>/dev/null && cd "$STORE" && pwd || true)"

usage() {
  echo "Usage: $0 <path-to-book> [-- npm run upload:local-epub args...]" >&2
  echo "  Formats: .epub (or .mobi / .azw / .awz3 → EPUB via Calibre ebook-convert)" >&2
  echo "  Each run copies the file under REVIEW_PRIVATE_BOOKS_DIR (default: $ROOT/../.castalia-review-private-books)" >&2
  echo "  then: cd to bibliotech and npm run upload:local-epub -- [args] <epub-path>." >&2
  echo "  BIBLIOTECH_ROOT, REVIEW_PRIVATE_BOOKS_DIR override locations." >&2
}

die() { echo "Error: $*" >&2; exit 1; }

if [[ $# -lt 1 || "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  [[ $# -ge 1 && ( "${1:-}" == "-h" || "${1:-}" == "--help" ) ]] && exit 0
  exit 1
fi

IN_PATH="$1"
shift
if [[ "${1:-}" == "--" ]]; then
  shift
fi

if [[ -f "$IN_PATH" ]]; then
  IN_PATH="$(cd "$(dirname "$IN_PATH")" && pwd)/$(basename "$IN_PATH")"
else
  die "File not found: $IN_PATH"
fi

[[ -n "$STORE" && -d "$STORE" ]] || die "Cannot use private book store directory. Set REVIEW_PRIVATE_BOOKS_DIR to a writable path. Tried: ${REVIEW_PRIVATE_BOOKS_DIR:-"$ROOT/../.castalia-review-private-books"}"
[[ -n "$BIB" && -d "$BIB" ]] || die "bibliotech not found. Clone next to this repo (../bibliotech) or set BIBLIOTECH_ROOT. Expected: $ROOT/../bibliotech"
[[ -f "$BIB/package.json" ]] || die "bibliotech at $BIB has no package.json"
if ! grep -qE '"upload:local-epub"' "$BIB/package.json" 2>/dev/null; then
  die "bibliotech package.json is missing an upload:local-epub script (see docs/FACULTY_REVIEW_EPUBS.md in bibliotech)"
fi

BATCH_ID="$(date -u +%Y%m%dT%H%M%SZ)-$$"
BATCH_DIR="${STORE}/${BATCH_ID}"
mkdir -p "$BATCH_DIR" || die "Failed to create import dir: $BATCH_DIR"
ORIG_BASENAME="$(basename "$IN_PATH")"
cp "$IN_PATH" "${BATCH_DIR}/${ORIG_BASENAME}" || die "Failed to copy to private store"

ext="${IN_PATH##*.}"
ext_l="$(printf '%s' "$ext" | tr '[:upper:]' '[:lower:]')"

if [[ "$ext_l" == "epub" ]]; then
  EPUB_PATH="${BATCH_DIR}/${ORIG_BASENAME}"
else
  command -v ebook-convert >/dev/null 2>&1 || die "Non-EPUB input (.$ext_l) requires Calibre. Install and ensure \`ebook-convert\` is on PATH: https://calibre-ebook.com"
  stem="${ORIG_BASENAME%.*}"
  # Avoid odd characters in output name; use stem from original
  safe_stem="${stem//[^A-Za-z0-9._-]/_}"
  [[ -n "$safe_stem" ]] || safe_stem="import"
  CONVERTED="${BATCH_DIR}/${safe_stem}.bibliotech.epub"
  echo "Converting in private store: ${BATCH_DIR}/${ORIG_BASENAME} -> ${CONVERTED}"
  ebook-convert "${BATCH_DIR}/${ORIG_BASENAME}" "$CONVERTED" || die "ebook-convert failed"
  [[ -f "$CONVERTED" ]] || die "Expected EPUB not created: $CONVERTED"
  EPUB_PATH="$CONVERTED"
fi

EPUB_PATH="$(cd "$(dirname "$EPUB_PATH")" && pwd)/$(basename "$EPUB_PATH")"

echo "Private store: $BATCH_DIR"
echo "cd $BIB && npm run upload:local-epub --" "$@" "$EPUB_PATH"
cd "$BIB"
exec npm run upload:local-epub -- "$@" "$EPUB_PATH"
