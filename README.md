# schema-release-poc

Proof of concept for releasing JSON schemas with one tag per schema version,
plus one npm package that holds every version. The schemas here are mock
`component` and `service` schemas.

```
component/Component.json   latest component schema
component/sample.yaml
service/Service.json       latest service schema
service/sample.yaml
bundle/                    npm package definition (@test-org-th/sample-schemas)
```

## How a schema change is released

1. Open a PR that edits `component/Component.json` (and its sample). Use a
   conventional title: `feat: ...` is a minor bump, `fix: ...` a patch. Add
   `Release-As: x.y.z` to the commit body to pick the version yourself.
1. After merge, release-please opens or updates one `chore: release main` PR.
   It bumps the schema (`component/version.txt`, `schema_version` in the
   sample) and the npm package (`bundle/package.json`) together, with a
   changelog for each.
1. Merging that PR creates two releases:
   - `component-vx.y.z` with only `Component.json` attached. The changelog
     links to the diff against the previous version.
   - `bundle-va.b.c`, which builds `@test-org-th/sample-schemas` from every
     schema tag, publishes it to npm and attaches the `.tgz`.

Service works the same way with `service/` and `service-vx.y.z` tags.

## Diffs between versions

```sh
git diff component-v1.0.0 component-v1.1.0 -- component/Component.json
```

or on GitHub: `compare/component-v1.0.0...component-v1.1.0`.

## Using every version (CLI)

`main` only has the latest schema. The npm package has all of them, built by
`scripts/build-bundle.sh` from the tags:

```
schemas/index.json              versions per kind with tag and commit
schemas/v1.1.0/Component.json
schemas/v1.0.0/Service.json
```

See `examples/cli-consumer` for loading the schema a file asks for.
