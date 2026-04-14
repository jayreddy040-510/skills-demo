---
name: investigate
description: Investigate Vercel runtime failures with Vercel CLI by locating deployments, reading runtime logs, identifying root cause, and when the fix is clear and low-risk, implementing it and opening a PR with GitHub CLI (`gh`). Accept an optional user-provided error message/signature as directional context for what to prioritize resolving.
---

# Investigate Vercel Runtime Logs

Follow this workflow to diagnose quickly, resolve when safe, and raise a PR.
Prefer the scripts in `scripts/` for repeatable runs.
If the user provides an error message/signature, treat it as directional context for prioritization; do not require it as a script argument.

## 1) Load environment and validate auth

Run:

```bash
bash scripts/check-auth.sh
```

Require:
- GitHub CLI auth (`gh auth status` must be valid)
- Vercel auth via either:
  - valid `VERCEL_TOKEN` (preferred for non-interactive runs), or
  - existing local Vercel session (`vercel login`)

Recommended:
- `VERCEL_ORG_ID` and `VERCEL_PROJECT_ID` for non-interactive project targeting
- `VERCEL_SCOPE` (team or user scope slug) for explicit scope selection

`check-auth.sh` validates `VERCEL_TOKEN` when present. If the token is invalid, it automatically falls back to local Vercel session auth for CLI continuity.

If `~/.envrc` is unavailable, export values manually before running CLI commands.

## 2) Verify CLI context

If you need direct checks, run:

```bash
vercel whoami
gh auth status
```

If project is not linked, prefer non-interactive targeting:

```bash
VERCEL_ORG_ID=team_xxx VERCEL_PROJECT_ID=prj_xxx vercel list --yes
```

## 3) Find and inspect the failing deployment

Run:

```bash
vercel list --yes
vercel inspect <deployment-url>
```

## 4) Read runtime logs and identify root cause

Use:

```bash
bash scripts/fetch-logs.sh <deployment-url> [error-signature]
```

The script runs `vercel logs` with **`--expand`** (default table output truncates messages) and adds a **JSON** block for errors/warnings so nested stack traces and multi-line `message` / `logs[]` fields are visible. Pass an optional error signature as the second argument for filtered expanded + JSON sections.

Classify:
- configuration issue (env vars, missing secrets, wrong scope/project)
- app bug (server action/API/runtime exception)
- external dependency/network failure
- transient platform noise

## 5) Resolve only when succinct and low-risk

Resolve immediately when:
- root cause is clear from logs
- change is narrow and local
- fix does not need broad architecture decisions

If not clearly resolvable, stop at diagnosis and report evidence + options.

## 6) Raise PR with `gh` when fix is applied

Do not ask the user for additional permission once a low-risk fix is applied; proceed automatically.

Run:

```bash
bash scripts/create-fix-pr.sh <short-cause> [changed-files...]
```

Behavior:
- creates/uses a `fix/investigate-*` branch
- commits and pushes the fix
- opens a PR targeting `main` using the body template in `assets/pr-body-template.md` (replace the `_(_...)_` placeholder bullets with real content after opening, e.g. `gh pr edit --body-file` on a completed copy)
- prints `PR_URL=<github-pr-url>` for direct sharing

## 7) Final output format

Always include:
- deployment URL + environment
- minimal root-cause statement with log evidence
- whether fix was applied
- PR URL to `main` (if opened) or exact blocker
