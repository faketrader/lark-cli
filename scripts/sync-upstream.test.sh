#!/usr/bin/env bash
# SPDX-License-Identifier: MIT

set -euo pipefail

sync_script="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/sync-upstream.sh"
test_repo=$(mktemp -d)
trap 'rm -rf -- "$test_repo"' EXIT

cd "$test_repo"
git init -q --initial-branch=main
git config user.name 'Sync Test'
git config user.email 'sync-test@example.com'
mkdir -p .github/workflows skills
printf 'base CI\n' > .github/workflows/ci.yml
printf 'base skill\n' > skills/example.md
git add .
git commit -qm 'Base'
git branch upstream

printf 'fork CI\n' > .github/workflows/ci.yml
printf 'fork sync\n' > .github/workflows/sync-upstream.yml
printf 'fork manifest\n' > plugin.json
git add .
git commit -qm 'Package the plugin'
fork_head=$(git rev-parse HEAD)

git switch -q upstream
printf 'upstream CI\n' > .github/workflows/ci.yml
printf 'upstream workflow\n' > .github/workflows/new.yml
printf 'updated skill\n' > skills/example.md
git add .
git commit -qm 'Update skill and workflows'
git switch -q main

bash "$sync_script" upstream
git merge-base --is-ancestor upstream HEAD
git diff --exit-code "$fork_head" HEAD -- .github/workflows plugin.json
test "$(cat skills/example.md)" = 'updated skill'

merged_head=$(git rev-parse HEAD)
bash "$sync_script" upstream
test "$(git rev-parse HEAD)" = "$merged_head"

printf 'fork skill edit\n' > skills/example.md
git commit -qam 'Edit skill in fork'
fork_head=$(git rev-parse HEAD)
git switch -q upstream
printf 'upstream skill edit\n' > skills/example.md
git commit -qam 'Edit skill upstream'
git switch -q main

if bash "$sync_script" upstream; then
  echo 'Expected the sync to stop on a skill conflict.' >&2
  exit 1
fi
test "$(git rev-parse HEAD)" = "$fork_head"
test -z "$(git status --porcelain)"

echo 'Upstream sync tests passed.'
