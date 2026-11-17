#!/usr/bin/env bash
# Builds the npm package that holds every released schema version.
# main only has the latest schema of each kind, so older versions are read
# from their release tags: component-v1.1.0 -> schemas/v1.1.0/Component.json
# Only tags contained in HEAD are used, so a bundle tag always rebuilds the
# same package.
#
# Usage: scripts/build-bundle.sh <out-dir> <package-version>
set -euo pipefail

out=${1:?out dir}
version=${2:?package version}

rm -rf "$out"
mkdir -p "$out/schemas"

index='{}'
for kind in component service; do
  case $kind in
    component) file=Component.json ;;
    service) file=Service.json ;;
  esac

  entries='[]'
  for tag in $(git tag -l "$kind-v*" --merged HEAD --sort=-v:refname); do
    v=${tag#"$kind-"}
    mkdir -p "$out/schemas/$v"
    git show "$tag:$kind/$file" >"$out/schemas/$v/$file"
    jq empty "$out/schemas/$v/$file"
    entries=$(jq -c --arg v "$v" --arg tag "$tag" \
      --arg commit "$(git rev-list -n 1 "$tag")" \
      '. + [{version: $v, tag: $tag, commit: $commit}]' <<<"$entries")
  done

  if [ "$entries" = '[]' ]; then
    echo "::warning::no $kind-v* tags yet"
    continue
  fi
  index=$(jq -c --arg kind "$kind" --argjson e "$entries" \
    '.[$kind] = {latest: $e[0].version, versions: $e}' <<<"$index")
done

jq . <<<"$index" >"$out/schemas/index.json"
jq --arg v "$version" '.version = $v' bundle/package.json >"$out/package.json"
cp bundle/README.md "$out/README.md"

echo "Built $out with $(jq -r '.component.versions // [] | length' <<<"$index") component" \
  "and $(jq -r '.service.versions // [] | length' <<<"$index") service schemas"
