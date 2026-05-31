#!/usr/bin/env bash
set -euo pipefail

# Guardrailed production deploy for the `portfolio` Vercel project
# (www.lawrencentim.com).
#
# Why this exists: the project is git-connected but `sourceless`, so a plain
# `git push` does NOT auto-deploy — `vercel --prod` is the real deploy path.
# And `vercel --prod` uploads the current WORKING TREE (incl. uncommitted and
# untracked files), so this surfaces git state first to avoid shipping stale or
# unintended changes. The 136MB reference PDF is kept out of uploads by
# .vercelignore (Vercel ignores .gitignore).
#
# Usage: ./deploy.sh

cd "$(dirname "$0")"

echo "→ Checking git state..."
if [ -n "$(git status --porcelain)" ]; then
  echo
  echo "⚠️  Working tree has changes that WILL be deployed but are not committed:"
  git status --short
  echo
  read -r -p "Deploy this working tree anyway? [y/N] " ans </dev/tty
  case "$ans" in
    [yY] | [yY][eE][sS]) ;;
    *) echo "Aborted — commit or stash first."; exit 1 ;;
  esac
else
  echo "✓ Working tree clean (HEAD $(git rev-parse --short HEAD), branch $(git branch --show-current))"
fi

echo "→ Deploying to production..."
vercel --prod
