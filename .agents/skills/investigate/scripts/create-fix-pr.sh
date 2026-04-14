#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: bash scripts/create-fix-pr.sh <short-cause> [changed-files...]" >&2
  exit 1
fi

SHORT_CAUSE="$1"
shift || true

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$SCRIPT_DIR/../assets/pr-body-template.md"

SLUG="$(echo "$SHORT_CAUSE" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-')"
SLUG="${SLUG%-}"
BRANCH="fix/investigate-${SLUG}"
TITLE="fix: address vercel runtime error ${SHORT_CAUSE}"

if git rev-parse --verify "$BRANCH" >/dev/null 2>&1; then
  git checkout "$BRANCH"
else
  git checkout -b "$BRANCH"
fi

if [ "$#" -gt 0 ]; then
  git add "$@"
else
  git add -A
fi

git commit -m "$TITLE"
git push -u origin HEAD

if [ ! -f "$TEMPLATE" ]; then
  echo "error: missing PR body template at $TEMPLATE" >&2
  exit 1
fi

COMMIT_SHORT="$(git rev-parse --short HEAD)"
BODY_FILE="$(mktemp)"
trap 'rm -f "$BODY_FILE"' EXIT

# Fill {{INV_*}} placeholders (works without gettext envsubst).
SHORT_CAUSE="$SHORT_CAUSE" BRANCH="$BRANCH" COMMIT_SHORT="$COMMIT_SHORT" TEMPLATE="$TEMPLATE" BODY_FILE="$BODY_FILE" python3 <<'PY'
import os
from pathlib import Path

template_path = Path(os.environ["TEMPLATE"])
out_path = Path(os.environ["BODY_FILE"])
text = template_path.read_text()
for key, val in (
    ("INV_SHORT_CAUSE", os.environ["SHORT_CAUSE"]),
    ("INV_BRANCH", os.environ["BRANCH"]),
    ("INV_COMMIT", os.environ["COMMIT_SHORT"]),
):
    text = text.replace("{{" + key + "}}", val)
out_path.write_text(text)
PY

PR_URL="$(gh pr create --base main --title "$TITLE" --body-file "$BODY_FILE")"

echo "PR_URL=$PR_URL"
