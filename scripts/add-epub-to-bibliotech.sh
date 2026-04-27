#!/usr/bin/env bash
# Add an EPUB to bibliotech: runs `npm run upload:local-epub` in ../bibliotech.
# Documented in review README: bibliotech’s FACULTY_REVIEW_EPUBS.md. Typical: --review
#
# Usage:
#   ./scripts/add-epub-to-bibliotech.sh <path-to.epub> [extra args for npm...]
#   BIBLIOTECH_ROOT=/path/to/bibliotech ./scripts/add-epub-to-bibliotech.sh book.epub --review
#
# Set BIBLIOTECH_ROOT to override the default (this repo’s ../bibliotech).

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BIB="${BIBLIOTECH_ROOT:-"$ROOT/../bibliotech"}"
BIB="$(cd "$BIB" 2>/dev/null && pwd || true)"

usage() {
  echo "Usage: $0 <path-to.epub> [-- npm run upload:local-epub args...]" >&2
  echo "  Default: cd to $ROOT/../bibliotech and run npm run upload:local-epub -- [args] <epub>." >&2
  echo "  Override directory with BIBLIOTECH_ROOT. Example: $0 ./book.epub -- --review" >&2
}

die() { echo "Error: $*" >&2; exit 1; }

if [[ $# -lt 1 || "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  [[ $# -ge 1 && ( "${1:-}" == "-h" || "${1:-}" == "--help" ) ]] && exit 0
  exit 1
fi

EPUB_PATH="$1"
shift

# If user passes a literal -- before npm flags, remove it
if [[ "${1:-}" == "--" ]]; then
  shift
fi

# Resolve to absolute for existence check and to pass a stable path to npm
if [[ -f "$EPUB_PATH" ]]; then
  EPUB_PATH="$(cd "$(dirname "$EPUB_PATH")" && pwd)/$(basename "$EPUB_PATH")"
else
  die "EPUB not found: $EPUB_PATH"
fi

[[ -n "$BIB" && -d "$BIB" ]] || die "bibliotech not found. Clone it next to this repo (../bibliotech) or set BIBLIOTECH_ROOT. Expected: $ROOT/../bibliotech"
[[ -f "$BIB/package.json" ]] || die "bibliotech at $BIB has no package.json"

if ! grep -qE '"upload:local-epub"' "$BIB/package.json" 2>/dev/null; then
  die "bibliotech package.json is missing an upload:local-epub script (see docs/FACULTY_REVIEW_EPUBS.md in bibliotech)"
fi

echo "cd $BIB && npm run upload:local-epub --" "$@" "$EPUB_PATH"
cd "$BIB"
exec npm run upload:local-epub -- "$@" "$EPUB_PATH"
