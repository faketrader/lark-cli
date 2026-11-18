#!/usr/bin/env bash
# SPDX-License-Identifier: MIT

set -euo pipefail

sync_script="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/sync-upstream.sh"
test_repo=$(mktemp -d)
trap 'rm -rf -- "$test_repo"' EXIT

expect_plugin_version() {
  node - "$1" <<'JS'
const assert = require('node:assert/strict');
const expected = process.argv[2];
for (const path of ['./plugin.json', './.claude-plugin/plugin.json']) {
  assert.equal(require(path).version, expected);
}
JS
}

cd "$test_repo"
git init -q --initial-branch=main
git config user.name 'Sync Test'
git config user.email 'sync-test@example.com'
mkdir -p .github/workflows .claude-plugin skills
printf 'base CI\n' > .github/workflows/ci.yml
printf 'released skill\n' > skills/example.md
printf 'released CLI\n' > cli.txt
git add .
git commit -qm 'First release'
git tag v1.2.3
git branch upstream

printf 'fork CI\n' > .github/workflows/ci.yml
printf 'fork sync\n' > .github/workflows/sync-upstream.yml
printf 'preview skill\n' > skills/example.md
printf '{"name":"lark-cli"}\n' > plugin.json
cp plugin.json .claude-plugin/plugin.json
git add .
git commit -qm 'Package the plugin'

bash "$sync_script" v1.2.3 v1.2.3
expect_plugin_version 1.2.3
git diff --exit-code v1.2.3 HEAD -- skills
fork_head=$(git rev-parse HEAD)

git switch -q upstream
printf 'upstream CI\n' > .github/workflows/ci.yml
printf 'upstream workflow\n' > .github/workflows/new.yml
printf 'updated skill\n' > skills/example.md
printf 'updated CLI\n' > cli.txt
git add .
git commit -qm 'Update skill and workflows'
git tag v1.2.4
printf 'unreleased skill\n' > skills/example.md
git commit -qam 'Continue developing upstream'
git switch -q main

bash "$sync_script" v1.2.4 v1.2.4
git merge-base --is-ancestor v1.2.4 HEAD
git diff --exit-code "$fork_head" HEAD -- .github/workflows
git diff --exit-code v1.2.4 HEAD -- skills cli.txt
expect_plugin_version 1.2.4

merged_head=$(git rev-parse HEAD)
bash "$sync_script" v1.2.4 v1.2.4
test "$(git rev-parse HEAD)" = "$merged_head"

printf 'fork CLI edit\n' > cli.txt
git commit -qam 'Edit CLI in fork'
fork_head=$(git rev-parse HEAD)
git switch -q upstream
printf 'upstream CLI edit\n' > cli.txt
git commit -qam 'Edit CLI upstream'
git tag v1.2.5
git switch -q main

if bash "$sync_script" v1.2.5 v1.2.5; then
  echo 'Expected the sync to stop on a CLI conflict.' >&2
  exit 1
fi
test "$(git rev-parse HEAD)" = "$fork_head"
test -z "$(git status --porcelain)"
expect_plugin_version 1.2.4

echo 'Upstream sync tests passed.'
