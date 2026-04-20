#!/usr/bin/env bash
# Upsert CNAME review.castalia.institute → GitHub Pages for this repo’s org.
# Requires: CLOUDFLARE_API_TOKEN (Zone.DNS Edit), jq, curl.
#
# Optional env:
#   ZONE_NAME=castalia.institute
#   RECORD_NAME=review
#   GITHUB_PAGES_CNAME_TARGET=inquiryinstitute.github.io
#   PROXIED=1   (set to 0 for DNS-only / grey cloud)

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
II_ROOT="$(cd "$ROOT/../Inquiry.Institute" 2>/dev/null && pwd || true)"
# Load Cloudflare token from this repo or sibling Inquiry.Institute (matches .env.local.example).
for envfile in "$ROOT/.env" "$ROOT/.env.local" "$II_ROOT/.env" "$II_ROOT/.env.local"; do
  if [[ -n "$envfile" && -f "$envfile" ]]; then
    set -a
    # shellcheck disable=SC1090
    source "$envfile"
    set +a
  fi
done

CLOUDFLARE_API_TOKEN="${CLOUDFLARE_API_TOKEN:-${CLOUDFLARE_TOKEN:-}}"
ZONE_NAME="${ZONE_NAME:-castalia.institute}"
RECORD_NAME="${RECORD_NAME:-review}"
GITHUB_PAGES_CNAME_TARGET="${GITHUB_PAGES_CNAME_TARGET:-inquiryinstitute.github.io}"
PROXIED_JSON='true'
if [[ "${PROXIED:-1}" == "0" ]]; then
  PROXIED_JSON='false'
fi

die() { echo "Error: $*" >&2; exit 1; }
[[ -n "$CLOUDFLARE_API_TOKEN" ]] || die "Set CLOUDFLARE_API_TOKEN (e.g. from Inquiry.Institute .env.local)"
command -v curl >/dev/null || die "curl required"
command -v jq >/dev/null || die "jq required"

ZONE_ID=$(curl --http1.1 -sS -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
  "https://api.cloudflare.com/client/v4/zones?name=${ZONE_NAME}" | jq -r '.result[0].id // empty')
[[ -n "$ZONE_ID" ]] || die "No Cloudflare zone for ${ZONE_NAME}"

payload=$(jq -n \
  --arg type "CNAME" \
  --arg name "$RECORD_NAME" \
  --arg content "$GITHUB_PAGES_CNAME_TARGET" \
  --argjson ttl 1 \
  --argjson proxied "$PROXIED_JSON" \
  '{type:$type,name:$name,content:$content,ttl:$ttl,proxied:$proxied}')

echo "Upsert CNAME ${RECORD_NAME}.${ZONE_NAME} -> ${GITHUB_PAGES_CNAME_TARGET} (proxied=${PROXIED_JSON})"

existing=$(curl --http1.1 -sS -G -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
  --data-urlencode "type=CNAME" \
  --data-urlencode "name=${RECORD_NAME}.${ZONE_NAME}" \
  "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records" | jq -r '.result[0].id // empty')

if [[ -n "$existing" ]]; then
  curl --http1.1 -sS -X PUT "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records/${existing}" \
    -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
    -H "Content-Type: application/json" \
    --data "$payload" | jq '{success, errors}'
else
  curl --http1.1 -sS -X POST "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records" \
    -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
    -H "Content-Type: application/json" \
    --data "$payload" | jq '{success, errors}'
fi
