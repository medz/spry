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

**Migration guide**: [https://spry.fun/migration](https://spry.fun/migration#spry-5-to-spry-6)

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
