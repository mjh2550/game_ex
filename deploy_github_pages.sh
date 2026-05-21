#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${GITHUB_PAGES_REPO:-https://github.com/mjh2550/mjh2550.github.io.git}"
BRANCH="${GITHUB_PAGES_BRANCH:-main}"
BASE_HREF="${GITHUB_PAGES_BASE_HREF:-/}"
COMMIT_MESSAGE="${GITHUB_PAGES_COMMIT_MESSAGE:-Deploy Mini Game Hub web}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

cd "$ROOT_DIR"

echo "==> Building Flutter web"
flutter pub get
flutter build web --release --base-href "$BASE_HREF" --dart-define=SCORE_BACKEND=local

echo "==> Preparing deploy worktree"
rsync -a \
  --delete \
  --exclude='.DS_Store' \
  --exclude='.last_build_id' \
  build/web/ "$TMP_DIR/"
touch "$TMP_DIR/.nojekyll"

cd "$TMP_DIR"
git init -q
git checkout -b "$BRANCH" -q
git add .
git -c user.name="${GIT_AUTHOR_NAME:-Codex}" \
  -c user.email="${GIT_AUTHOR_EMAIL:-codex@local}" \
  commit -m "$COMMIT_MESSAGE"
git remote add origin "$REPO_URL"

echo "==> Pushing to $REPO_URL ($BRANCH)"
git push origin "$BRANCH" --force

echo "==> Done"
echo "Open: https://mjh2550.github.io/"
