---
title: Middleware → Request ID
description: Add or reuse request IDs in Spry with the first-party requestId middleware.
---

# Request ID

`requestId(...)` gives each request a stable request ID and exposes it through `event.locals`.

Import it from the first-party middleware entrypoint:

```dart
import 'package:spry/middleware.dart';
```

## What it does

By default, `requestId(...)`:

- reads `x-request-id` from the incoming request when present
- trusts and reuses that value by default
- generates a new ID when the request header is missing
- stores the selected value in `event.locals[#requestId]`
- fills the response `x-request-id` header when it is missing
- does not override the response header if downstream code already set it

## Basic usage

Use it in global middleware:

```dart
// middleware/01_request_id.dart
import 'package:spry/middleware.dart';
import 'package:spry/spry.dart';

final middleware = requestId();
```

A handler can then read the value from `event.locals`:

```dart
import 'package:spry/spry.dart';

Response handler(Event event) {
  final requestId = event.locals.get<String>(#requestId);
  return Response.json({'requestId': requestId});
}
```

## API

```dart
Middleware requestId({
  String headerName = 'x-request-id',
  Symbol localKey = #requestId,
  FutureOr<String> Function(Event event)? generator,
  bool trustIncoming = true,
});
```

## Options

### `headerName`

Changes the request and response header name.

### `localKey`

Changes the `event.locals` key used to store the selected request ID.

### `generator`

Provides a custom generator for new request IDs.

If not provided, Spry uses a lightweight timestamp-plus-random-suffix strategy.

### `trustIncoming`

Defaults to `true`.

When `true`, `requestId(...)` reuses an incoming request header value when it exists.

When `false`, Spry ignores the incoming header and always generates a new request ID.

## Response header behavior

`requestId(...)` is intentionally conservative.

It fills the response header only when the response does not already define that header.

That means downstream handlers can still set a different response request ID explicitly when needed.

## When to use it

Use `requestId(...)` when you want:

- request tracing in logs
- easier debugging across middleware and handlers
- a stable correlation ID in JSON error responses
- compatibility with gateways or proxies that already send `x-request-id`

If your application already has a stronger tracing layer, use the `generator` hook or a custom middleware wrapper to align the formats.
