#!/usr/bin/env bash
# SPDX-License-Identifier: MIT

set -euo pipefail

release_ref=${1:?Pass the fetched release ref}
release_tag=${2:?Pass the upstream release tag}
if [[ ! "$release_tag" =~ ^v([0-9]+\.[0-9]+\.[0-9]+)$ ]]; then
  printf 'Expected a stable release tag such as v1.2.3, got %s\n' "$release_tag" >&2
  exit 1
fi
version=${BASH_REMATCH[1]}
release_commit=$(git rev-parse --verify "$release_ref^{commit}")
git cat-file -e "$release_commit:skills"
base_commit=$(git rev-parse HEAD)

if [[ -n "$(git status --porcelain)" ]]; then
  echo 'Upstream sync requires a clean working tree.' >&2
  exit 1
fi

if ! git merge-base --is-ancestor "$release_commit" "$base_commit"; then
  if ! git merge --no-ff --no-commit "$release_commit"; then
    git rev-parse --quiet --verify MERGE_HEAD >/dev/null || exit 1
  fi

  # Keep the fork's workflows so the standard GITHUB_TOKEN can push the merge.
  git restore --source="$base_commit" --staged --worktree -- .github/workflows
fi

# The published skill bundle must match the version shown by plugin managers.
git restore --source="$release_commit" --staged --worktree -- skills

conflicts=$(git diff --name-only --diff-filter=U)
if [[ -n "$conflicts" ]]; then
  printf 'Resolve these upstream merge conflicts before retrying:\n%s\n' "$conflicts" >&2
  git merge --abort
  exit 1
fi

node - "$version" <<'JS'
const fs = require('node:fs');
const version = process.argv[2];
const paths = ['plugin.json', '.claude-plugin/plugin.json'];
const manifests = paths.map(path => JSON.parse(fs.readFileSync(path, 'utf8')));

for (const [index, path] of paths.entries()) {
  const manifest = manifests[index];
  if (manifest.version === version) continue;
  manifest.version = version;
  fs.writeFileSync(path, JSON.stringify(manifest, null, 2) + '\n');
}
JS
git add -- plugin.json .claude-plugin/plugin.json

if git diff --cached --quiet && ! git rev-parse --quiet --verify MERGE_HEAD >/dev/null; then
  printf 'Already synced with %s.\n' "$release_tag"
  exit 0
fi

git commit -m "chore(sync): sync larksuite/cli $release_tag"
