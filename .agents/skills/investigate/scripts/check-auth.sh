#!/usr/bin/env bash
set -euo pipefail

if [ -f "$HOME/.envrc" ]; then
  # shellcheck disable=SC1090
  source "$HOME/.envrc"
fi

if ! command -v vercel >/dev/null 2>&1; then
  echo "Missing required CLI: vercel" >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "Missing required CLI: gh" >&2
  exit 1
fi

echo "Checking Vercel auth..."
if [ -n "${VERCEL_TOKEN:-}" ]; then
  if vercel whoami --token "$VERCEL_TOKEN" >/dev/null 2>&1; then
    echo "Vercel auth passed via VERCEL_TOKEN."
  else
    echo "Warning: VERCEL_TOKEN is invalid. Falling back to local Vercel session." >&2
    unset VERCEL_TOKEN
    vercel whoami >/dev/null
    echo "Vercel auth passed via local session."
  fi
else
  vercel whoami >/dev/null
  echo "Vercel auth passed via local session."
fi

echo "Checking GitHub auth..."
gh auth status >/dev/null

echo "Auth checks passed."
