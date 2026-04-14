#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: bash scripts/fetch-logs.sh <deployment-url> [error-signature]" >&2
  exit 1
fi

DEPLOYMENT_URL="$1"
QUERY="${2:-}"

if [ -f "$HOME/.envrc" ]; then
  # shellcheck disable=SC1090
  source "$HOME/.envrc"
fi

# Prefer token auth when valid, otherwise fall back to local Vercel session.
if [ -n "${VERCEL_TOKEN:-}" ] && ! vercel whoami --token "$VERCEL_TOKEN" >/dev/null 2>&1; then
  unset VERCEL_TOKEN
fi

VERCEL_ARGS=()
if [ -n "${VERCEL_SCOPE:-}" ]; then
  VERCEL_ARGS+=(--scope "$VERCEL_SCOPE")
fi
if [ -n "${VERCEL_PROJECT_ID:-}" ]; then
  VERCEL_ARGS+=(--project "$VERCEL_PROJECT_ID")
else
  PROJECT_NAME="$(
    vercel inspect "$DEPLOYMENT_URL" "${VERCEL_ARGS[@]}" 2>&1 \
      | awk '/^[[:space:]]+name[[:space:]]+/ { print $2; exit }' || true
  )"
  if [ -n "${PROJECT_NAME:-}" ]; then
    VERCEL_ARGS+=(--project "$PROJECT_NAME")
  fi
fi

# --no-follow: historical snapshot; --expand: full message (default table view truncates).
BASE_LOG_ARGS=(--no-follow "${VERCEL_ARGS[@]}")

echo "== error/warn logs (expanded) =="
vercel logs "$DEPLOYMENT_URL" "${BASE_LOG_ARGS[@]}" --level error --level warning --expand

echo
echo "== error/warn logs (json; full nested messages) =="
vercel logs "$DEPLOYMENT_URL" "${BASE_LOG_ARGS[@]}" --level error --level warning --json

echo
echo "== lambda logs (expanded) =="
vercel logs "$DEPLOYMENT_URL" "${BASE_LOG_ARGS[@]}" --source serverless --expand

echo
echo "== edge logs (expanded) =="
vercel logs "$DEPLOYMENT_URL" "${BASE_LOG_ARGS[@]}" --source edge-function --expand

if [ -n "$QUERY" ]; then
  echo
  echo "== query: $QUERY (expanded) =="
  vercel logs "$DEPLOYMENT_URL" "${BASE_LOG_ARGS[@]}" --query "$QUERY" --expand
  echo
  echo "== query: $QUERY (json) =="
  vercel logs "$DEPLOYMENT_URL" "${BASE_LOG_ARGS[@]}" --query "$QUERY" --json
fi
