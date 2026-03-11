## Unreleased

- feat(routing): upgrade to `roux` `0.5.x` and keep Spry catch-all scopes aligned with the new `**` remainder syntax.
- feat(scanner): add expressive file-route segments for embedded params, regex params, optional params, repeated params, and single-segment wildcards.

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
