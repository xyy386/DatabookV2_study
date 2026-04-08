#!/bin/zsh

set -euo pipefail

REPO_DIR="/Users/xingyiyao/Desktop/Databook/study"
BRANCH="main"
REMOTE="origin"
SYNC_DIR="$REPO_DIR/.git-sync"
LOG_DIR="$SYNC_DIR/logs"
LOCK_DIR="$SYNC_DIR/.lock"
TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S %z')"

mkdir -p "$LOG_DIR"

if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  exit 0
fi

cleanup() {
  rmdir "$LOCK_DIR" 2>/dev/null || true
}

trap cleanup EXIT

exec >> "$LOG_DIR/sync.log" 2>&1

echo "[$TIMESTAMP] sync started"

cd "$REPO_DIR"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "[$TIMESTAMP] not a git repository"
  exit 1
fi

git add -A

if ! git diff --cached --quiet; then
  git commit -m "auto-sync: $TIMESTAMP"
fi

if git ls-remote --exit-code --heads "$REMOTE" "$BRANCH" >/dev/null 2>&1; then
  git pull --rebase "$REMOTE" "$BRANCH"
fi

git push -u "$REMOTE" "$BRANCH"

echo "[$TIMESTAMP] sync finished"

