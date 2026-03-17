---
title: Guide → Request Context
description: Every handler and middleware function receives the same request-scoped Event object.
---

# Request Context

Spry passes an `Event` object through handlers, middleware, and error handlers. This is the request context you actually work with.

## What you will use most

- `event.request`
- `event.params`
- `event.locals`
- `event.context`
- `event.method`
- `event.path`

## Params

Use `event.params` for file-routing values:

```dart
final id = event.params.required('id');
final slug = event.params.wildcard;
```

Helpers include:

- `required(name)`
- `int(name)`
- `num(name)`
- `double(name)`
- `decode(name, decoder)`
- `$enum(name, values)`
- `wildcard`

## Locals

Use `event.locals` for request-scoped data shared across middleware and handlers:

```dart
Future<Response> middleware(Event event, Next next) async {
  event.locals.set(#requestId, DateTime.now().microsecondsSinceEpoch.toString());
  return next();
}
```

## Runtime awareness

Use `event.context.runtime.name` when you need to surface or inspect the active runtime:

```dart
return Response.json({
  'runtime': event.context.runtime.name,
  'path': event.url.path,
});
```

Keep runtime awareness in responses or diagnostics. Routing itself should still be driven by the filesystem.
