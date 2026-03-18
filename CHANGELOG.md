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
