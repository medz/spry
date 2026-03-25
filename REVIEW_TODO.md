# OpenAPI Implementation Review — Tracking TODO

Verified findings from code review. Each item maps to one commit.

---

## Fixes

### example
- [ ] **fix(example)**: Add missing `UserId` schema in `example/openapi/spry.config.dart`
  - `User` schema references `#/components/schemas/UserId` but `UserId` is never defined in `components.schemas`

### builder
- [ ] **fix(builder)**: Handle `OpenAPIConfig` instance in `_copyWithOpenApi` (`lib/src/builder/config.dart`)
  - `_copyWithOpenApi` only handles `Map` input; if the caller passes an `OpenAPIConfig` instance directly it silently falls through — add explicit handling or assertion

### scanner
- [ ] **fix(scanner)**: `normalizeReferencedElement` safe null return (`lib/src/builder/scanner_semantics.dart`)
  - Parameter is `Element?` but body calls `element!` unconditionally — should return `null` (or the expected fallback) instead of throwing
- [ ] **fix(scanner)**: `_makeSchemaNullable` should preserve `$ref` and composed schemas (`lib/src/builder/scanner_openapi.dart`)
  - Current: when no `type` key exists it adds `type: ['null']`, which is invalid for `$ref`/`oneOf`/`anyOf`/`allOf` schemas
  - Fix: wrap the original schema in `anyOf: [schema, {type: 'null'}]` when there is no explicit `type`
- [ ] **fix(scanner)**: Add `example`/`examples` mutual exclusion check in scanner parameter evaluation
  - OpenAPI 3.1 disallows both `example` and `examples` on the same parameter; scanner should emit a build error when both are present

### openapi objects
- [ ] **fix(openapi)**: Consistent scope strings in `OpenAPILicense` (`lib/src/openapi/info.dart`)
  - Factory uses `scope: 'OpenAPILicense'`; `fromJson` uses `scope: 'openapi.document.info.license'` — pick one convention and apply it consistently
- [ ] **fix(openapi)**: `_prefixExtensions` double-prefix guard (all openapi files that call it)
  - If a caller accidentally passes `'x-foo'` instead of `'foo'`, the key becomes `'x-x-foo'` — guard by stripping a leading `x-` before prepending
- [ ] **fix(openapi)**: `example`/`examples` mutual exclusion guard in `OpenAPIParameter.query` (and other locations) (`lib/src/openapi/parameter.dart`)
  - Constructor accepts both fields without asserting they are mutually exclusive
- [ ] **fix(openapi)**: Eager validation in `server._stringList` (`lib/src/openapi/server.dart`)
  - Uses `value.cast<String>()` which is a lazy cast — fails at iteration time, not construction time; use an eager loop instead
- [ ] **fix(openapi)**: Defensive cast in `OpenAPIOperation.fromJson` (`lib/src/openapi/operation.dart`)
  - `json.cast<String, Object?>()` can throw `TypeError` at runtime if the map contains non-String keys — validate before casting
- [ ] **fix(openapi)**: Defensive cast in `config._requireStringListMap` (`lib/src/builder/config.dart`)
  - Uses `entry.key as String` and `(entry.value as List).cast<String>()` — both can throw; validate with proper error messages
- [ ] **fix(openapi)**: Simplify nullable switch null/default branch in `schema.dart` (`lib/src/openapi/schema.dart`)
  - `nullable` switch has both `null =>` and `_ =>` returning `['null']` — the `null` case is unreachable; remove it

## Refactors

- [ ] **refactor(openapi)**: Extract `_prefixExtensions` / `_extractExtensions` to a shared `_utils.dart` file
  - The helpers are duplicated across ~12 openapi files; extract once and import everywhere

## Chores

- [ ] **chore(openapi)**: Sort `lib/openapi.dart` exports alphabetically
  - `oauth.dart` appears after `operation.dart`; `link.dart` appears after `response.dart`

## Tests

- [ ] **fix(test)**: Replace internal import in `test/openapi/core_objects_test.dart`
  - Imports `package:spry/src/openapi/config.dart` (internal path) — should use `package:spry/config.dart`
- [ ] **test(openapi)**: Add `oauth2`, `openIdConnect`, `mutualTLS` coverage in security tests (`test/openapi/security_test.dart`)
  - Current tests only cover `apiKey` and `http`; the three remaining factories are untested
- [ ] **refactor(test)**: Extract `_decodeJsonValue` to a shared test helper
  - The helper is duplicated across multiple test files; move it to `test/openapi/helpers.dart` (or similar) and import it
- [ ] **fix(test)**: Fix misleading deep-clone mutation test in `test/generator_test.dart`
  - Test mutates post-serialization JSON (which is always independent) — rewrite to mutate the in-memory `paths` map before serialization to actually exercise the deep-clone path

---

## Skipped (invalid / too risky)

- `example/openapi/README.md` `dart run spry openapi` — command does not exist; README would be misleading
- `scanner_semantics.dart` `definedNames2` — internal analyzer API; too risky to change without upstream guidance
- `test/cli_test.dart` `_createRepoTempDir` — only defined once; not actually duplicated
