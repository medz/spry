---
name: spry-docs
description: Use when building, reviewing, debugging, or documenting a Spry application or the Spry framework itself. Covers the Spry authoring model (`routes/`, `middleware/`, `public/`, `hooks.dart`, `spry.config.dart`), route and middleware behavior, OpenAPI and client generation, runtime targets, validation commands, and how to choose between docs, app source, generated `.spry/` output, examples, and framework internals.
---

# Spry Docs

Use this skill when the task involves:

- implementing or reviewing Spry route handlers
- adding or debugging global `middleware/`, scoped `_middleware.dart`, or `_error.dart`
- changing `spry.config.dart`, runtime targets, output layout, or deploy behavior
- generating or debugging OpenAPI documents and typed clients
- contributing to the Spry framework, examples, or docs

## Start from the authoring model

A Spry app is usually explained by these files and folders:

- `routes/`: request handlers plus scoped `_middleware.dart` and `_error.dart`
- `middleware/`: global middleware collected in filename order
- `public/`: static assets served directly for `GET` and `HEAD`
- `hooks.dart`: startup and shutdown hooks
- `spry.config.dart`: runtime target, serve/build behavior, and layout overrides
- `.spry/`: generated output written by `spry build` or `spry serve`

Always check `spry.config.dart` before assuming defaults. `routesDir`, `middlewareDir`, `publicDir`, and `outputDir` can move the usual paths.

Keep the pipeline small in your head:

1. load config
2. scan the project tree
3. build route, middleware, and error metadata
4. generate runtime and optional client/OpenAPI artifacts
5. write output
6. optionally compile for non-Dart targets

## Choose the right source of truth

Start from the cheapest source that can answer the question:

- Framework docs and README: first choice for normal usage questions. Read `README.md`, `sites/spry.medz.dev/getting-started.md`, `sites/spry.medz.dev/guide/app.md`, `sites/spry.medz.dev/guide/routing.md`, `sites/spry.medz.dev/guide/openapi.md`, `sites/spry.medz.dev/guide/client.md`, `sites/spry.medz.dev/config.md`, and `sites/spry.medz.dev/deploy/index.md`.
- App source tree: first choice for behavior in a specific Spry app. Inspect the configured route tree, middleware tree, `hooks.dart`, `public/`, and `spry.config.dart`.
- Generated output: inspect `.spry/` or the configured `outputDir` when the question depends on emitted runtime files, route generation, target wrappers, or whether OpenAPI/client generation actually ran.
- Framework internals: inspect `lib/src/builder/scanner.dart`, `lib/src/builder/generator.dart`, `lib/src/routing.dart`, `lib/src/app.dart`, `bin/src/serve.dart`, `bin/src/build.dart`, and `lib/src/builder/target_spec.dart` only when docs and app code do not fully explain behavior.

Do not jump straight into framework internals for ordinary app work. Start from the app tree and docs unless the task is explicitly about Spry itself.

## Repo knowledge base

When working inside the Spry framework repository, use `AGENTS.md` as the maintainer-oriented map for:

- public API boundaries
- important framework internals
- validation commands
- release-facing norms

## Common workflows

See [references/recipes.md](references/recipes.md) for focused playbooks covering:

- adding or changing routes
- choosing scoped vs global middleware and error handling
- configuring OpenAPI and client generation
- changing runtime targets and deploy output
- deciding when generated output inspection is necessary
- validating app changes versus framework changes

## Validation defaults

For the Spry framework repository:

```bash
dart analyze
dart test
```

When docs change in the framework repo:

```bash
cd sites/spry.medz.dev
npm run docs:build
```

For a Spry application, prefer the smallest command that proves the behavior you touched:

- `dart run spry serve` for local route and middleware behavior
- `dart run spry build` when generated output or deploy artifacts matter
- `dart run spry build client` when only the typed client matters

If a task changes route parsing, generation, CLI behavior, or target output in the framework itself, keep tests, examples, and docs aligned in the same patch.
