## Unreleased

**Migration guide**: Not required.

### Highlights

- To be filled in at release time.

### Breaking Changes

- None.

### What's New

- None yet.

### Migration note

- None yet.

### Full Changelog

- To be filled in at release time.

## v8.5.2

**Migration guide**: Not required.

### Highlights

Spry 8.5.2 fixes the `analyzer` constraint so Spry can once again coexist with
current `unrouter` releases inside Flutter applications while still letting the
application-level solver pick a compatible analyzer version.

### Breaking Changes

- None.

### What's New

#### Ecosystem compatibility

- Changed Spry's `analyzer` constraint from `^9.0.0` to `^10.0.1` so it
  overlaps with `oref` / `unrouter` again, which restores dependency solving
  for Flutter applications that use both packages by
  [@medz](https://github.com/medz) in
  [#194](https://github.com/medz/spry/issues/194).

### Migration note

- No migration is required for existing Spry applications.
- Flutter applications depending on both Spry and `unrouter` should now resolve
  again under the current Flutter SDK dependency graph.

### Full Changelog

- https://github.com/medz/spry/compare/v8.5.1...v8.5.2

## v8.5.1

**Migration guide**: Not required.

### Highlights

Spry 8.5.1 fixes Flutter project dependency resolution by aligning Spry's
`analyzer` constraint with the current Flutter SDK dependency graph, and
refreshes the docs site with clearer product positioning plus new comparison
pages.

### Breaking Changes

- None.

### What's New

#### Flutter compatibility

- Aligned Spry's `analyzer` constraint with the Flutter SDK so a minimal
  Flutter application can depend on `spry` without hitting the SDK-pinned
  `meta` conflict triggered by `analyzer >=10.0.2` by
  [@medz](https://github.com/medz) in
  [534d594](https://github.com/medz/spry/commit/534d594).

#### Documentation and site

- Refreshed the README and docs homepage positioning to explain Spry's value
  proposition more clearly by [@medz](https://github.com/medz) in
  [5e493b4](https://github.com/medz/spry/commit/5e493b4).
- Added dedicated `What is Spry` and framework comparison pages to the docs
  site by [@medz](https://github.com/medz) in
  [749682e](https://github.com/medz/spry/commit/749682e) and
  [fb4fba8](https://github.com/medz/spry/commit/fb4fba8).
- Updated the docs site's social preview image by
  [@medz](https://github.com/medz) in
  [b3d48d1](https://github.com/medz/spry/commit/b3d48d1).
- Bumped the docs site's Vite dependency to `7.3.2` by
  [@dependabot[bot]](https://github.com/apps/dependabot) in
  [#193](https://github.com/medz/spry/pull/193).

### Migration note

- No migration is required for existing Spry applications.
- Flutter applications that depend on Spry no longer need to work around the
  `analyzer` / `meta` solver conflict introduced by newer analyzer releases.

### Full Changelog

- https://github.com/medz/spry/compare/v8.5.0...v8.5.1

## v8.5.0

**Migration guide**: Not required.

### Highlights

Spry 8.5.0 introduces the first stable release of Spry Client, adds
handler-local composition through `defineHandler(...)`, and exposes a reusable
Scalar docs handler for OpenAPI reference pages.

This release adds first-party client generation under `spry build client`,
introduces generated route helpers plus typed params / inputs / queries /
headers / outputs / models, adds a dedicated client runtime surface under
`package:spry/client.dart`, and aligns build, OpenAPI, and client generation
with a shared stream-driven pipeline.

### Breaking Changes

- None.

### What's New

#### Spry Client

- Added first-party Spry Client generation under `spry build client`, with
  generated `SpryClient`, `*Routes`, and route-mirrored client source output by
  [@medz](https://github.com/medz) in
  [#182](https://github.com/medz/spry/pull/182).
- Added generated typed client artifacts including `*Params`, `*Input`,
  `*Query`, `*Headers`, `*Output`, and shared `models/*`, with route metadata
  as the base input and OpenAPI metadata as type enhancement by
  [@medz](https://github.com/medz) in
  [#182](https://github.com/medz/spry/pull/182).
- Added generated request construction and typed response decoding through the
  new client runtime surface in `package:spry/client.dart`, built on `oxy` and
  `ht` primitives by [@medz](https://github.com/medz) in
  [#182](https://github.com/medz/spry/pull/182).

#### Build pipeline

- Reworked the builder around a unified stream-based pipeline so scanning,
  generation, writing, OpenAPI artifacts, and client artifacts all flow
  through the same build model by [@medz](https://github.com/medz) in
  [#182](https://github.com/medz/spry/pull/182).
- Improved build progress reporting to follow real scan and generation events
  while keeping generated output and final build summaries explicit by
  [@medz](https://github.com/medz) in
  [#182](https://github.com/medz/spry/pull/182).

#### Runtime and OpenAPI API

- Added `defineHandler(...)` so a single route handler can attach a small local
  middleware chain and a dedicated local error handler while preserving Spry's
  outer middleware and scoped error pipeline by
  [@medz](https://github.com/medz) in
  [#183](https://github.com/medz/spry/pull/183).
- Added `servePublicAsset` to `package:spry/spry.dart` and consolidated the
  public runtime exports under the main entrypoint, while deprecating
  `package:spry/app.dart` ahead of 9.0 by
  [@medz](https://github.com/medz) in
  [#184](https://github.com/medz/spry/pull/184).
- Added `defineScalarHandler(...)` to `package:spry/openapi.dart` so
  applications can serve a Scalar-powered API reference directly, and updated
  generated OpenAPI docs routes to use the shared handler by
  [@medz](https://github.com/medz) in
  [#187](https://github.com/medz/spry/pull/187).

#### Documentation and examples

- Added a dedicated Spry Client guide and a focused `example/client_example/`
  project covering generated client structure, configuration, output layout,
  typed inputs, queries, headers, outputs, and shared models by
  [@medz](https://github.com/medz) in
  [#182](https://github.com/medz/spry/pull/182).
- Updated the docs site tooling to VitePress 2 alpha and refreshed site code
  block styling by [@medz](https://github.com/medz) in
  [#185](https://github.com/medz/spry/pull/185).

### Migration note

- No migration is required for existing applications.
- To generate a typed client package, add a `client: ClientConfig(...)` block
  to `defineSpryConfig(...)`, then run `dart run spry build client`.
- OpenAPI artifact output remains optional. Route-level OpenAPI metadata can
  still enhance the generated client even when `openapi.json` is not emitted.
- `package:spry/app.dart` is now deprecated; prefer `package:spry/spry.dart`
  and plan to migrate before 9.0.

### Full Changelog

- https://github.com/medz/spry/compare/v8.4.1...v8.5.0

## v8.4.0

**Migration guide**: Not required.

### Highlights

Spry 8.4.0 adds first-party middleware helpers, an OpenAPI docs UI route, and
new routing configuration options on top of the `roux 1.0.1` upgrade.

This release introduces built-in `requestId(...)`, `timing(...)`, and
middleware composition helpers under `package:spry/middleware.dart`, adds
`Scalar()` UI support for generated OpenAPI docs, improves `spry build` /
`spry serve` terminal output, and exposes `caseSensitive` plus optional
handler-route LRU caching through both `Spry(...)` and `defineSpryConfig(...)`.

### Breaking Changes

- None.

### What's New

#### Middleware

- Added first-party `requestId(...)` middleware with request/response header
  propagation and `useRequestId(event)` access by
  [@medz](https://github.com/medz) in
  [#177](https://github.com/medz/spry/pull/177).
- Added first-party `timing(...)` middleware for `server-timing` response
  metrics by [@medz](https://github.com/medz) in
  [#178](https://github.com/medz/spry/pull/178).
- Added first-party middleware composition helpers `every(...)`, `except(...)`,
  and `some(...)` under `package:spry/middleware.dart` by
  [@medz](https://github.com/medz) in
  [#179](https://github.com/medz/spry/pull/179).

#### Routing and configuration

- Upgraded Spry's routing internals to `roux 1.0.1` by
  [@medz](https://github.com/medz) in
  [#180](https://github.com/medz/spry/pull/180).
- Added `caseSensitive` to both `Spry(...)` and `defineSpryConfig(...)` so
  applications can opt into case-insensitive route matching without changing
  the default behavior by [@medz](https://github.com/medz) in
  [#180](https://github.com/medz/spry/pull/180).
- Added optional `handlerCacheCapacity` to enable `roux` LRU caching for
  handler lookups in both runtime and generated-app configuration by
  [@medz](https://github.com/medz) in
  [#180](https://github.com/medz/spry/pull/180).

#### OpenAPI and CLI

- Added `Scalar()` UI support so generated OpenAPI output can also expose an
  interactive docs route during `spry build` and `spry serve` by
  [@medz](https://github.com/medz) in
  [#175](https://github.com/medz/spry/pull/175).
- Improved `spry build` and `spry serve` terminal output with clearer progress,
  route/middleware counts, next-step commands, docs links, local/network URLs,
  and OpenAPI UI hints by [@medz](https://github.com/medz) in
  [#176](https://github.com/medz/spry/pull/176).

#### Documentation and examples

- Added dedicated middleware documentation for the new first-party helpers and
  clarified method-scoped middleware / error file naming in the guides by
  [@medz](https://github.com/medz) in
  [#177](https://github.com/medz/spry/pull/177),
  [#178](https://github.com/medz/spry/pull/178),
  [#179](https://github.com/medz/spry/pull/179), and
  [#180](https://github.com/medz/spry/pull/180).

### Migration note

- No migration is required for existing applications.
- To adopt the new middleware helpers, import `package:spry/middleware.dart`.
- To tune routing behavior, set `caseSensitive` or `handlerCacheCapacity` in
  `Spry(...)` or `defineSpryConfig(...)`.
- To expose interactive API docs, configure `openapi.ui: Scalar(...)` in
  `spry.config.dart`.

### Full Changelog

- https://github.com/medz/spry/compare/v8.3.0...v8.4.0

## v8.3.0

**Migration guide**: Not required.

### Highlights

Spry adds first-class OpenAPI 3.1 generation driven by filesystem routes and
typed route metadata.

This work introduces document generation from `spry.config.dart`, typed
OpenAPI builders under `package:spry/openapi.dart`, analyzer-validated
route-level `openapi` metadata, lifted route `globalComponents`, and a focused
example plus documentation for the full authoring flow.

### Breaking Changes

- None.

### What's New

#### OpenAPI generation

- Added `openapi` configuration in `spry.config.dart`, including document root
  metadata, output selection, component merge strategy, and root-level webhook
  declarations by [@medz](https://github.com/medz) in
  [#171](https://github.com/medz/spry/pull/171).
- Added a public typed OpenAPI authoring surface under
  `package:spry/openapi.dart`, including builders for schemas, parameters,
  headers, request bodies, responses, security schemes, OAuth flows, callbacks,
  path items, tags, servers, and document components by
  [@medz](https://github.com/medz) in
  [#171](https://github.com/medz/spry/pull/171).
- Added route-level top-level `openapi` metadata with analyzer-backed truth
  source validation, so route docs must resolve to Spry's real OpenAPI types
  rather than raw maps or local lookalikes by
  [@medz](https://github.com/medz) in
  [#171](https://github.com/medz/spry/pull/171).
- Added support for deeply reusable shared spec values, including nested child
  and sub-child values such as parameters, request bodies, responses,
  callbacks, security requirements, server variables, and `globalComponents`
  buckets by [@medz](https://github.com/medz) in
  [#171](https://github.com/medz/spry/pull/171).
- Added OpenAPI document generation to the build pipeline, including route-path
  conversion, method expansion for any-method routes, explicit-method override
  rules, `HEAD` handling, and lifted route `globalComponents` by
  [@medz](https://github.com/medz) in
  [#171](https://github.com/medz/spry/pull/171).
- Added strict and deep-merge component merge strategies with source-aware
  conflict diagnostics by [@medz](https://github.com/medz) in
  [#171](https://github.com/medz/spry/pull/171).

#### Documentation and examples

- Added a dedicated OpenAPI guide covering config, route metadata, reusable
  spec composition, schemas, request/response modeling, security, callbacks,
  webhooks, merge behavior, and output rules by
  [@medz](https://github.com/medz) in
  [#171](https://github.com/medz/spry/pull/171).
- Added a standalone `example/openapi/` project that generates
  `public/openapi.json` from document-level components and route-level
  `globalComponents` by [@medz](https://github.com/medz) in
  [#171](https://github.com/medz/spry/pull/171).
- Aligned the README runtime-target overview with the v8.2 target surface by
  [@medz](https://github.com/medz) in
  [eaa9ff7](https://github.com/medz/spry/commit/eaa9ff72e7b52fa48d1c6965be2e72c9840d4d11).

### Migration note

- No migration is required. OpenAPI support is additive. To adopt it, add an
  `openapi` block to `defineSpryConfig(...)`, import
  `package:spry/openapi.dart`, and start attaching typed `openapi` metadata to
  route files.

### Full Changelog

- https://github.com/medz/spry/compare/v8.2.0...v8.3.0

## v8.2.0

**Migration guide**: [https://spry.medz.dev/migration](https://spry.medz.dev/migration)

### Highlights

Spry 8.2.0 reshapes generated output around a clearer target layout and adds
new Dart-native deployment targets.

This release renames the Dart runtime target to `BuildTarget.vm`, moves
generated Dart source into `.spry/src/`, renames JS runtime entrypoints to
their deploy-facing filenames, adds `exe` / `aot` / `jit` / `kernel` targets,
and removes the synthetic wildcard-param alias for named catch-all routes.

### Breaking Changes

- Renamed `BuildTarget.dart` to `BuildTarget.vm` by
  [@medz](https://github.com/medz) in
  [#170](https://github.com/medz/spry/pull/170).
- Generated Dart source files now live under `.spry/src/` instead of the
  `.spry/` root, and JS target entrypoints now use deploy-facing filenames such
  as `.spry/node/index.cjs` and `.spry/cloudflare/index.js` by
  [@medz](https://github.com/medz) in
  [#170](https://github.com/medz/spry/pull/170).
- Removed `RouteParams.wildcard` / `event.params.wildcard` for named catch-all
  routes. Read the declared param directly, for example
  `event.params.get('slug')` by [@medz](https://github.com/medz) in
  [dab62e9](https://github.com/medz/spry/commit/dab62e9a74e6b2f6639e3c117b5455f7882b8542).

### What's New

#### Build and deployment

- Added Dart-native deployment targets for executable, AOT snapshot, JIT
  snapshot, and kernel snapshot output via `BuildTarget.exe`,
  `BuildTarget.aot`, `BuildTarget.jit`, and `BuildTarget.kernel` by
  [@medz](https://github.com/medz) in
  [#170](https://github.com/medz/spry/pull/170).
- Reworked generated output layout and deployment documentation across Node,
  Bun, Deno, Cloudflare, Vercel, and Netlify to match the new target-specific
  entrypoints by [@medz](https://github.com/medz) in
  [#170](https://github.com/medz/spry/pull/170).
- Synced `public/` assets into Dart compiled output workspaces so native builds
  can be deployed directly by [@medz](https://github.com/medz) in
  [#170](https://github.com/medz/spry/pull/170).

#### Runtime performance

- Cached parsed request URLs and query params per request to remove duplicate
  parsing in the main request pipeline by [@medz](https://github.com/medz) in
  [#167](https://github.com/medz/spry/pull/167).
- Simplified the static asset serving pipeline and unified public-asset
  resolution across JS and IO runtimes by [@medz](https://github.com/medz) in
  [#169](https://github.com/medz/spry/pull/169).

#### Routing runtime

- Removed generated `_withWildcardParam` wrappers and the per-request
  `Event` / `RouteParams` rebuild they performed for named catch-all routes by
  [@medz](https://github.com/medz) in
  [dab62e9](https://github.com/medz/spry/commit/dab62e9a74e6b2f6639e3c117b5455f7882b8542).

### Migration note

- Rename `BuildTarget.dart` to `BuildTarget.vm` in `spry.config.dart`.
- If your tooling reads generated output directly, update paths from `.spry/*.dart`
  to `.spry/src/*.dart`, and switch JS entrypoints to the new filenames
  (`node/index.cjs`, `bun/index.js`, `deno/index.js`, `cloudflare/index.js`).
- Replace `event.params.wildcard` with `event.params.get('<name>')`, where
  `<name>` is the identifier declared in `[...name].dart`.

### Full Changelog

- https://github.com/medz/spry/compare/v8.1.0...v8.2.0

## v8.1.0

**Migration guide**: Not required.

### Highlights

Spry 8.1.0 expands runtime coverage and adds first-class route-level WebSocket handling without changing the filesystem routing model.

This release adds Deno and Netlify targets, exposes public `osrv` runtime entrypoints for target-aware integrations, upgrades Spry to `osrv 0.6.x`, and introduces the new `event.ws` API for WebSocket upgrades inside normal route handlers.

### Breaking Changes

- None.

### What's New

#### Runtime targets

- Added a Deno target and deploy documentation by [@medz](https://github.com/medz) in [#164](https://github.com/medz/spry/pull/164).
- Added a Netlify target, example project, and deploy documentation by [@medz](https://github.com/medz) in [#163](https://github.com/medz/spry/pull/163).

#### Runtime integration

- Added public `package:spry/osrv.dart` runtime entrypoints, including target-specific exports for Dart, Node, Bun, Cloudflare, Deno, Vercel, and Netlify by [@medz](https://github.com/medz) in [#162](https://github.com/medz/spry/pull/162).
- Upgraded Spry to `osrv 0.6.x` as part of the Deno runtime work by [@medz](https://github.com/medz) in [#164](https://github.com/medz/spry/pull/164).

#### WebSocket support

- Added `event.ws` with runtime support checks, upgrade-request detection, requested protocol access, and `upgrade(...)` for route-level WebSocket handling by [@medz](https://github.com/medz) in [#165](https://github.com/medz/spry/pull/165).
- Added WebSocket documentation covering handshake semantics, session boundaries, and runtime support expectations by [@medz](https://github.com/medz) in [#165](https://github.com/medz/spry/pull/165).

### Migration note

- No migration is required for existing applications. To adopt WebSockets, import `package:spry/websocket.dart` and use `event.ws` inside a normal route handler.
- If you integrate directly with `osrv`, prefer the new public exports under `package:spry/osrv.dart` and its target-specific entrypoints.

### Full Changelog

- https://github.com/medz/spry/compare/v8.0.0...v8.1.0

## v8.0.0

**Migration guide**: [https://spry.medz.dev/migration](https://spry.medz.dev/migration)

### Highlights

Spry 8.0.0 aligns the framework with the latest upstream HTTP and routing foundations.

This release upgrades Spry to the Fetch-style `Request` / `Response` model from `ht 0.3.x` and `osrv 0.4.x`, adopts the `roux 0.5.x` route syntax changes, and expands filesystem routing with more expressive segment patterns.

### Breaking Changes

- Spry now follows the upstream Fetch-style `Request` / `Response` construction model by @medz in [#157](https://github.com/medz/spry/pull/157).
- Manual string-path remainder matches must now use `/**` instead of `/*` when constructing `Spry`, `MiddlewareRoute`, or `ErrorRoute` by @medz in [#155](https://github.com/medz/spry/pull/155).

#### Request / Response construction

If you construct exported `Request` / `Response` values directly, migrate to the new init-object form:

- `Request(uri, method: 'GET')` -> `Request(uri, RequestInit(method: HttpMethod.get))`
- `Response(status: 404, headers: ..., body: ...)` -> `Response(body, ResponseInit(status: 404, headers: ...))`

### What's New

#### HTTP foundation upgrade

- Upgraded to `ht 0.3.1` and `osrv 0.4.x` by @medz in [#157](https://github.com/medz/spry/pull/157).
- Re-exported `RequestInit` and `ResponseInit` from `package:spry/spry.dart` and `package:spry/app.dart` by @medz in [#157](https://github.com/medz/spry/pull/157).

#### Routing upgrade

- Upgraded to `roux 0.5.x` by @medz in [#155](https://github.com/medz/spry/pull/155).
- Kept Spry catch-all scopes aligned with the new `**` remainder syntax by @medz in [#155](https://github.com/medz/spry/pull/155).
- Added richer filesystem route syntax for embedded params, regex params, optional params, repeated params, and single-segment wildcards by @medz in [#155](https://github.com/medz/spry/pull/155).

#### Examples and docs

- Split examples by target runtime and added a `knex_dart` example project by @medz in [`13fed0d`](https://github.com/medz/spry/commit/13fed0d99e266f138ac84d62d44a4014229070c1).
- Refreshed migration docs and release-facing website copy for the v8 release by @medz in [#159](https://github.com/medz/spry/pull/159).
- Upgraded project dependencies by @medz in [#160](https://github.com/medz/spry/pull/160).

### Migration note

- Replace manual `/*` route strings with `/**` in `Spry`, `MiddlewareRoute`, and `ErrorRoute`, then re-run your route matching tests after upgrading to `roux` `0.5.x`.
- If you construct exported `Request` / `Response` types directly, migrate to the new Fetch-style init objects. For example:
  `Request(uri, method: 'GET')` -> `Request(uri, RequestInit(method: HttpMethod.get))`
  `Response(status: 404, headers: ..., body: ...)` -> `Response(body, ResponseInit(status: 404, headers: ...))`
  `Response.text(...)` / `Response.empty(...)` -> `Response(..., ResponseInit(...))`

### Full Changelog

- https://github.com/medz/spry/compare/v7.0.0...v8.0.0

## v7.0.0

**Migration guide**: [https://spry.medz.dev/migration](https://spry.medz.dev/migration)

### What's Changed

- BREAKING: replace the imperative app DSL with the v7 file-based runtime model built around `routes/`, scoped `_middleware.dart` / `_error.dart`, and `spry.config.dart`.
- feat(cli): add `spry serve` and `spry build` workflows for generated runtimes, including watch mode and explicit root support.
- feat(runtime): add generated targets for Dart VM, Node.js, Bun, Cloudflare Workers, and Vercel.
- feat(builder): add config loading, route scanning, runtime generation, and public asset syncing for the new build pipeline.
- docs: rewrite the documentation site for Spry v7, including the new getting started, runtime, deploy, and migration guides.

## v6.2.0

- feat: support middleware operators (`|` Pipe middleware, `>` middleware with handler)
- feat: support group routing (`app.group(...)`)
- docs: add group routes docs

## v6.1.0

- perf(datr, server): pointless waiting
- perf: avoid creating event id
- refactor: Remove `event.id`

## v6.0.1

- fix: avoid http response status

## v6.0.0

**Migration guide**: [https://spry.medz.dev/migration](https://spry.medz.dev/migration)

### What's Changed

- refactor: remove group router (The `app.group`/`app.grouped`).
- refactor: rename `app.stack` to `app.middleware`.
- refactor: remove `useRequest()`, now use `event.request`.
- refactor: remove `useHeaders()`, now use `event.headers`/`event.request.headers`.
- refactor: remove `getClientAddress()`, now use `event.address`.
- refactor: remove `useRequestURI()`, now use `event.url`.
- refactor: remove `useParams()`, now use `event.params`.
- refactor: rename factory `Response.text()` to `Response.fromString()`.
- refactor: rename factory `Response.json()` to `Response.fromJson()`.
- refactor: remove all adapter, now is cross-platform.
