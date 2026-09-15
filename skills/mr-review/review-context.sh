#!/usr/bin/env bash
# Gathers everything needed to review the last N commits in the current worktree.
# Output is injected into the skill prompt before Claude sees it.
set -euo pipefail

# Accept "3", "last 3 commits", or nothing (defaults to 5).
N="$(printf '%s' "$*" | grep -oE '[0-9]+' | head -1 || true)"
N="${N:-5}"

ROOT="$(git rev-parse --show-toplevel)"
BRANCH="$(git rev-parse --abbrev-ref HEAD)"

if BASE="$(git rev-parse --verify -q "HEAD~${N}")"; then
  :
else
  BASE="$(git rev-list --max-parents=0 HEAD | tail -1)"
  echo "NOTE: branch has fewer than ${N} commits; reviewing from the root commit."
fi

echo "Worktree:  ${ROOT}"
echo "Branch:    ${BRANCH}"
echo "Range:     ${BASE}..HEAD (last ${N} commits)"
echo

echo "=== Commits ==="
git log --no-merges --format='%h  %ad  %an  %s' --date=short "${BASE}..HEAD"
echo

echo "=== Files changed ==="
git diff --stat "${BASE}..HEAD"
echo

# Guard against dumping a 20k-line diff into context.
LINES="$(git diff --numstat "${BASE}..HEAD" | awk '{a+=$1; d+=$2} END {print a+d+0}')"
if [ "${LINES}" -gt 4000 ]; then
  echo "NOTE: diff is ${LINES} changed lines. Only the stat is shown above."
  echo "Run targeted 'git diff ${BASE}..HEAD -- <path>' on the files that matter."
else
  echo "=== Diff (${BASE}..HEAD) ==="
  git diff --unified=5 "${BASE}..HEAD"
fi
echo

echo "=== Merge request ==="
if command -v glab >/dev/null 2>&1; then
  glab mr view 2>/dev/null || echo "No MR found for branch ${BRANCH}."
else
  echo "glab CLI not installed."
fi
