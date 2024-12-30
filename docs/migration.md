---
title: Migration guide
description: Spry includes some behavior and API changes that you need to consider applying when migrating.
---

# Migration guide

{{ $frontmatter.description }}

## Spry 5 to Spry 6

### App instance

- `app.stack` -> `app.middleware`
- `app.group`/`app.grouped` -> Removed it, Use the `app.use` replace.

### Request

- `useRequest()` -> `event.request`
- `useHeaders()` -> `event.headers`/`event.request.headers`
- `getClientAddress()` -> `event.address`
- `useRequestURI()` -> `event.url`
- `useParams()` -> `event.params`

### Adapters

Please remove your adapter code, including `to{Platform}Handler`, and use `app.serve` instead:

Before:

:::code-group
```dart [dart:io]
final handler = toIOHandler(app);
final server = await HttpServer.bind('127.0.0.1', 3000);

server.listen(handler);
```

```dart [Other e.g Bun]
final serve = toBunServe(app)
  ..port = 3000;

Bun.serve(serve);
```
:::

Now:
```dart
final server = app.serve(port: 3000);
await server.ready();
```

### WebSockets

- TODO
