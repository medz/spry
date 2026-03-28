# AGENTS

This file is the repository knowledge base for collaborators and future AI agents working on Spry.

It should help a new contributor quickly understand:

- what Spry is
- how the repository is organized
- where to make changes
- how to validate work
- how commits, PRs, changelogs, and releases should be written

## Project Summary

Spry is a Dart server framework centered on filesystem routing and generated runtime output.

The authoring model is:

- application routes live in `routes/`
- global middleware lives in `middleware/`
- scoped middleware and error handlers live inside `routes/` as `_middleware.dart` and `_error.dart`
- build/runtime behavior lives in `spry.config.dart`
- generated runtime output goes to `.spry/` by default

Spry targets multiple runtimes:

- Dart VM
- Node.js
- Bun
- Cloudflare Workers
- Vercel
- Netlify Functions

## Core Mental Model

The core pipeline is:

1. load config
2. scan the project tree
3. build a route tree
4. generate runtime entry files
5. write generated output
6. optionally compile JS for non-Dart targets

In practice:

- `spry serve` runs the pipeline and starts a dev/runtime process
- `spry build` runs the pipeline and emits deployable artifacts

Spry is intentionally explicit:

- the filesystem is the source of truth for route structure
- generated output is inspectable
- route behavior should not be hidden behind a large imperative DSL

## Important Repository Areas

### Public API

- `lib/spry.dart`
  main framework export surface
- `lib/app.dart`
  smaller app-oriented export surface
- `lib/config.dart`
  `defineSpryConfig(...)` and target enums
- `lib/builder.dart`
  builder-facing exports for config, scanning, and generation

### Runtime and Framework Internals

- `lib/src/app.dart`
  main `Spry` request handling pipeline
- `lib/src/routing.dart`
  route, middleware, and error router construction
- `lib/src/event.dart`
  request-scoped context passed to handlers
- `lib/src/errors.dart`
  `HTTPError` and framework error conversion
- `lib/src/public*.dart`
  static asset serving across runtimes

### Build Pipeline

- `lib/src/builder/config.dart`
  load and merge build config
- `lib/src/builder/scanner.dart`
  scan routes, middleware, errors, and hooks from the project tree
- `lib/src/builder/route_tree.dart`
  in-memory metadata model for scanned files
- `lib/src/builder/generator.dart`
  emit generated `app.dart`, `hooks.dart`, and `main.dart`
- `lib/src/builder/target_spec.dart`
  target-specific generation details

### CLI

- `bin/spry.dart`
  CLI entrypoint
- `bin/src/build.dart`
  `spry build`
- `bin/src/serve.dart`
  `spry serve`
- `bin/src/build_pipeline.dart`
  shared pipeline orchestration
- `bin/src/write.dart`
  write generated files and sync target assets

### Documentation and Site

- `README.md`
  package homepage and quick orientation
- `CHANGELOG.md`
  long-lived release history
- `sites/spry.medz.dev/`
  documentation source
- `sites/spry.medz.dev/snippets/`
  embedded docs snippets

### Examples

- `example/dart_vm/`
- `example/node/`
- `example/bun/`
- `example/cloudflare/`
- `example/vercel/`
- `example/netlify/`
- `example/knex_dart/`

These examples are useful smoke-test targets when runtime/build behavior changes.

## Routing Model

Spry uses filesystem routing.

Common mappings:

- `routes/index.dart` -> `/`
- `routes/about.get.dart` -> `GET /about`
- `routes/users/[id].dart` -> `/users/:id`
- `routes/[...slug].dart` -> `/**:slug`

Supported expressive segment syntax includes:

- embedded params
- regex params
- optional params
- repeated params
- single-segment wildcards

When changing route parsing behavior, always inspect:

- `lib/src/builder/scanner.dart`
- `test/scanner_test.dart`
- `test/generator_test.dart`
- docs in `sites/spry.medz.dev/guide/routing.md`

## HTTP and Runtime Model

Spry currently aligns with:

- `ht 0.3.x`
- `osrv 0.6.x`
- `roux 0.5.x`

Important current expectations:

- `Request` and `Response` use Fetch-style init objects
- manual remainder route strings must use `/**`, not `/*`
- `RequestInit` and `ResponseInit` are re-exported by Spry

When changing upstream alignment, verify:

- constructor examples in docs and README
- route syntax docs and examples
- `CHANGELOG.md`
- migration docs

## Typical Change Boundaries

### If you change public API

Also check:

- `lib/spry.dart`
- `lib/app.dart`
- examples
- docs snippets
- migration notes
- changelog entry

### If you change route scanning or generation

Also check:

- `scanner_test.dart`
- `generator_test.dart`
- docs routing examples
- generated output assumptions in CLI tests

### If you change CLI behavior

Also check:

- `bin/spry.dart`
- CLI tests
- help text
- README and docs command examples

### If you change runtime target output

Also check:

- `target_spec.dart`
- `build_pipeline.dart`
- target-specific examples
- deploy docs under `sites/spry.medz.dev/deploy/`

## Validation Checklist for Code Changes

Default validation commands:

```bash
dart analyze
dart test
```

When docs change:

```bash
cd sites/spry.medz.dev
npm run docs:build
```

When runtime/build behavior changes, smoke-test key examples:

```bash
cd example/dart_vm && dart pub get && dart run spry build
cd example/node && dart pub get && dart run spry build
cd example/bun && dart pub get && dart run spry build
cd example/cloudflare && dart pub get && dart run spry build
cd example/vercel && dart pub get && dart run spry build
cd example/netlify && dart pub get && dart run spry build
cd example/knex_dart && dart pub get && dart run spry build
```

When preparing a publish:

```bash
dart pub publish --dry-run
```

## Working Norms

- prefer focused changes over broad refactors
- keep examples and docs aligned with behavior changes
- keep generated/runtime semantics explicit and inspectable
- do not leave release-facing version branding stale
- prefer updating tests and migration docs in the same change as the behavior change

## Syntax Upgrade Guidance

When writing or updating Dart code in this repository, prefer the newer syntax
forms when they make the code smaller and clearer.

Rules:

- prefer dot shorthand where it is valid and improves readability
- prefer null-aware syntax where it keeps the code simpler and clearer
- choose the shorter form when dot shorthand is not actually more concise; for
  example, prefer `final openapi = OpenAPI(...)` over
  `final OpenAPI openapi = .new(...)`
- do not rewrite existing files only to upgrade syntax
- new files should follow these rules by default
- when modifying existing code, it is acceptable to upgrade the touched lines
  opportunistically if the result is clearer and remains local to the change

## Versioning Semantics

Spry follows semantic versioning, but version planning should also guide implementation behavior.

### Major releases

Major releases may introduce intentional breaking changes.

Rules:

- do not preserve old behavior only for compatibility if the new major version is intentionally redefining the contract
- prefer a clean new model over compatibility shims and legacy branches
- document user-facing breaking changes in migration docs, changelog entries, and release notes
- remove outdated examples and docs instead of preserving contradictory legacy behavior

### Minor and patch releases

Minor and patch releases should preserve existing public behavior unless the repository owner explicitly decides otherwise.

Rules:

- avoid silent breakage in public API or documented behavior
- prefer additive changes for minor releases
- reserve patch releases for fixes, small quality improvements, and non-breaking corrections

### What counts as breaking

Record a breaking change only when user-facing behavior changes in a meaningful way, for example:

- public API signatures change
- documented behavior changes
- route syntax or matching behavior changes
- build output or runtime expectations change
- migration work is required in downstream projects

Do not record a change as breaking when:

- the implementation changes internally but the public contract stays the same
- code is refactored without changing observable behavior
- internal structure changes but generated/public behavior is preserved

## Implementation Quality Constraints

Avoid low-signal or redundant implementation patterns.

### No empty forwarding functions

Do not introduce pass-through wrappers or empty forwarding helpers unless they provide real value, such as:

- a stable public API boundary
- target-specific behavior
- meaningful normalization or validation
- future-proofing that is already justified by current architecture

Bad pattern:

- a function whose only purpose is to call another function with the same arguments and no additional contract

### No redundant implementations

Do not duplicate logic across files or targets when the behavior is the same.

Prefer:

- extracting a shared helper
- moving shared logic downward into a common layer
- keeping target-specific layers thin when behavior is identical

Duplication is only acceptable when:

- target/runtime constraints genuinely differ
- keeping code separate materially improves clarity
- abstraction would be more confusing than the duplication

## Default Implementation Flow

Unless the task is clearly docs-only or otherwise exempt, use this default execution flow for features, fixes, and implementation PRs:

1. investigate the relevant code, tests, docs, and upstream references
2. write a local temporary spec markdown file describing the intended change
3. add or update the relevant tests first
4. run the targeted tests and confirm they fail so the test is proven effective
5. implement the feature or fix
6. run the targeted tests again and confirm they pass
7. run the full test suite to check for regressions
8. run formatting
9. run the analyzer and ensure there are no issues
10. delete the local temporary spec markdown file before finishing

Default command sequence, adjusted as needed for the task:

```bash
dart test <targeted-tests>
dart test
dart format .
dart analyze
```

Implementation flow notes:

- the temporary spec file is a local working artifact, not a committed project document unless the task explicitly calls for that
- the red-to-green test step is important for behavior changes and bug fixes
- if a task is docs-only, release-only, or otherwise not test-driven by nature, choose a lighter process intentionally instead of forcing the default flow
- if formatting or analyzer scope can be narrowed safely, that is acceptable, but the final state should still be clean

## Commit Rules

Use Conventional Commits.

Preferred types:

- `feat`
- `fix`
- `docs`
- `refactor`
- `perf`
- `test`
- `build`
- `ci`
- `chore`

Use a scope when it improves clarity.

Examples:

- `feat(routing): adopt roux 0.5 path syntax`
- `fix(scanner): reject param-name drift in route shapes`
- `docs(changelog): align v8 entry with release notes`

Use `BREAKING CHANGE:` in the footer when a commit introduces a breaking API or behavior change.

## Pull Request Rules

PR titles should also use Conventional Commit style.

Examples:

- `feat(http): upgrade to ht 0.3 and osrv 0.6`
- `chore(release): prepare v8.0.0`

Default PR body rule:

- leave the body empty unless the PR directly resolves a tracked issue

If the PR resolves an issue, use:

```text
Resolves #<id>
```

## Changelog Rules

`CHANGELOG.md` is the long-lived project record.

Each release entry should use this structure:

```md
## vX.Y.Z

**Migration guide**: <link-if-needed>

### Highlights

Short release summary.

### Breaking Changes

- User-facing breaking changes only.

### What's New

#### <Area>

- User-facing additions and improvements.

### Migration note

- Concrete upgrade actions.

### Full Changelog

- Compare link.
```

Changelog writing rules:

- optimize for historical accuracy over marketing copy
- group changes by user-facing area, not by internal commit order
- include author attribution and source references when useful
- prefer PR links when available
- use commit links only when work landed without a PR
- do not trust an existing unreleased section blindly when preparing a real release
- before publishing, rebuild the release entry from the actual diff between the previous released tag and the new release target
- verify the final release notes against real commits, merged PRs, and user-facing behavior changes

Attribution format in `CHANGELOG.md`:

- `by [@medz](https://github.com/medz) in [#157](https://github.com/medz/spry/pull/157)`
- `by [@medz](https://github.com/medz) in [13fed0d](https://github.com/medz/spry/commit/13fed0d99e266f138ac84d62d44a4014229070c1)`

## Release Rules

GitHub Releases use the same structure and ordering as `CHANGELOG.md`:

- `Highlights`
- `Breaking Changes`
- `What's New`
- `Migration Guide`
- `Full Changelog`

Release writing rules:

- optimize for the current release announcement, not for long-term archival wording
- keep the summary tighter than the changelog entry
- describe real user-facing changes only
- avoid raw commit lists as the main body
- do not assume a prewritten unreleased section is correct enough for publishing
- reconstruct the release summary from the actual range between the last released version and the new tag

Attribution format in GitHub Releases:

- prefer native GitHub mentions such as `@medz`
- prefer PR references such as `#157`
- use commit hashes only when no PR exists

## Changelog vs Release

The changelog and release body should contain the same substantive change summary.

The main formatting difference is attribution style:

- `CHANGELOG.md` should use explicit markdown links for people, PRs, and commits
- GitHub Releases should use native GitHub references such as `@user` and `#123` so GitHub links them automatically

## Release Preparation Checklist

Before publishing a new version:

1. update `pubspec.yaml`
2. finalize the release entry in `CHANGELOG.md`
3. update migration docs when the release has breaking changes
4. verify docs and release-facing branding if versioned wording exists
5. run `dart test`
6. run `dart pub publish --dry-run`
7. build the docs site
8. check CI on `main`
9. smoke-test key examples when the release changes runtime/build behavior
10. create and push the release tag
11. publish to pub.dev
12. create or update the GitHub Release body using the same structure
