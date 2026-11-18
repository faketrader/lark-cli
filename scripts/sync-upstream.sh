#!/usr/bin/env bash
# SPDX-License-Identifier: MIT

set -euo pipefail

upstream_ref=${1:?Pass the fetched upstream ref}
base_commit=$(git rev-parse HEAD)

if [[ -n "$(git status --porcelain)" ]]; then
  echo 'Upstream sync requires a clean working tree.' >&2
  exit 1
fi

if git merge-base --is-ancestor "$upstream_ref" "$base_commit"; then
  echo 'Upstream main is already merged.'
  exit 0
fi

if ! git merge --no-ff --no-commit "$upstream_ref"; then
  git rev-parse --quiet --verify MERGE_HEAD >/dev/null || exit 1
fi

# Keep the fork's workflow files so the standard GITHUB_TOKEN can push the merge.
git restore --source="$base_commit" --staged --worktree -- .github/workflows

conflicts=$(git diff --name-only --diff-filter=U)
if [[ -n "$conflicts" ]]; then
  printf 'Resolve these upstream merge conflicts before retrying:\n%s\n' "$conflicts" >&2
  git merge --abort
  exit 1
fi

git commit -m 'chore(sync): merge larksuite/cli main'
