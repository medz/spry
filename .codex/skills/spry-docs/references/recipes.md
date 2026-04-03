# Spry Docs Recipes

## Add or change a route

Start with:

- `spry.config.dart` to confirm `routesDir`
- `sites/spry.medz.dev/getting-started.md`
- `sites/spry.medz.dev/guide/routing.md`

Then inspect the app route tree. Common mappings:

- `routes/index.dart` -> `/`
- `routes/about.get.dart` -> `GET /about`
- `routes/users/[id].dart` -> `/users/:id`
- `routes/[...slug].dart` -> `/**:slug`

Use framework internals only when route matching or scanning looks wrong:

- `lib/src/builder/scanner.dart`
- `lib/src/routing.dart`
- `test/scanner_test.dart`
- `test/generator_test.dart`

Validate with:

```bash
dart run spry serve
```

Use `dart run spry build` as well when the generated runtime output matters.

## Choose scoped vs global middleware or error handling

Read:

- `sites/spry.medz.dev/guide/app.md`
- `sites/spry.medz.dev/guide/routing.md`
- `sites/spry.medz.dev/guide/handler.md`

Use:

- `middleware/` for global behavior collected in filename order
- `routes/**/_middleware.dart` for branch-local behavior
- `routes/**/_error.dart` for branch-local error mapping
- `defineHandler(...)` when middleware or error mapping belongs to only one route

Helpful examples:

- `example/dart_vm/middleware/01_logger.dart`
- `example/dart_vm/routes/_middleware.dart`
- `example/dart_vm/routes/_error.dart`

When framework behavior looks wrong, inspect:

- `lib/src/middleware.dart`
- `lib/src/middleware/combine.dart`
- `lib/src/errors.dart`
- `lib/src/app.dart`

## Configure OpenAPI output

Read:

- `sites/spry.medz.dev/guide/openapi.md`
- `sites/spry.medz.dev/config.md`

Key rule:

- `spry.config.dart` seeds the document and chooses output
- route files expose top-level `openapi` values for operation metadata
- Spry derives `paths` from the filesystem; do not hand-write them

Good references:

- `sites/spry.medz.dev/snippets/reference/openapi/spry.config.dart`
- `sites/spry.medz.dev/snippets/reference/openapi/routes.index.dart`
- `sites/spry.medz.dev/snippets/reference/openapi/shared.dart`
- `example/openapi/`

Inspect generated output only when you need to verify the merged document or generated route artifact.

## Configure client generation

Read:

- `sites/spry.medz.dev/guide/client.md`
- `example/client_example/README.md`

Key rule:

- route metadata is enough to generate a client
- OpenAPI metadata strengthens request and response typing, but client generation does not require `openapi.output`

Useful commands:

```bash
dart run spry build
dart run spry build client
```

Useful files:

- `example/client_example/server/spry.config.dart`
- `example/client_example/server/routes/`
- `example/client_example/client/lib/`

Inspect generated client files when a question is about output naming, type generation, or how route metadata became code.

## Change runtime target or deploy behavior

Read:

- `sites/spry.medz.dev/config.md`
- `sites/spry.medz.dev/deploy/index.md`
- the target-specific file under `sites/spry.medz.dev/deploy/`

Check:

- `spry.config.dart` `target`
- `ReloadStrategy` when the local dev loop matters
- `outputDir` or target-specific config such as `wranglerConfig`

If you are changing framework generation, inspect:

- `lib/src/builder/target_spec.dart`
- `bin/src/build_pipeline.dart`
- the matching example under `example/`

Smoke-test the example for the target you changed.

## Decide when generated output inspection is necessary

Inspect `.spry/` or the configured output directory when:

- a route or middleware exists in source but behaves differently at runtime
- OpenAPI or client artifacts are missing, stale, or named unexpectedly
- a target wrapper for Node, Bun, Deno, Cloudflare, Vercel, or Netlify looks wrong
- the task is about emitted files rather than authoring source

Do not inspect generated output first when the question is only about how to author a route, middleware file, or config option.

## Validation matrix

For a Spry app:

```bash
dart analyze
dart run spry serve
dart run spry build
```

Only run `dart run spry build client` when client generation is relevant.

For the Spry framework repo:

```bash
dart analyze
dart test
```

Add docs validation when docs changed:

```bash
cd sites/spry.medz.dev
npm run docs:build
```
