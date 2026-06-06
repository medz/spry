# Spry Middleware Reference

## Middleware Function Signature

```dart
import 'package:spry/spry.dart';

Future<Response> myMiddleware(Event event, Next next) async {
  // Before: inspect/modify request
  final response = await next();
  // After: inspect/modify response
  return response;
}
```

Call `next()` to pass control to the next layer. Return a `Response` directly to short-circuit the chain.

## Global Middleware

Place files in `middleware/` at the project root. Each file exports a handler function:

```dart
// middleware/logger.dart
import 'package:spry/spry.dart';

Future<Response> logger(Event event, Next next) async {
  final start = DateTime.now();
  final response = await next();
  print('${event.request.method} ${event.url.path} '
        '${response.status} ${DateTime.now().difference(start)}');
  return response;
}
```

Global middleware applies to **every** request.

## Scoped Middleware

Place `_middleware.dart` files inside `routes/` directories:

```text
routes/
  _middleware.dart       # applies to all routes
  admin/
    _middleware.dart     # applies to /admin/* only
    dashboard.dart
```

Scoped middleware runs before global middleware. Within scopes, more specific scopes run before broader ones.

## Method-Specific Middleware

Suffix middleware files to restrict by HTTP method:

- `middleware/auth.post.dart` — only for POST requests globally
- `routes/admin/_middleware.get.dart` — only for GET requests in `/admin/*`

## Middleware Execution Order

For a request to `GET /admin/users`:

1. `routes/admin/_middleware.dart` (scoped, most specific)
2. `routes/_middleware.dart` (scoped, less specific)
3. `middleware/*.dart` files (global)
4. Route handler for `/admin/users`

## Combining Middleware

Use `combine` to chain multiple middleware into one:

```dart
import 'package:spry/spry.dart';

final combined = combine([logger, auth, cors]);
```

Use `combineScoped` for scoped middleware chains.

## Built-in Middleware Helpers

Spry ships with first-party middleware utilities:

- `requestId` — adds X-Request-ID header
- `timing` — adds Server-Timing header
- `combine` / `combineScoped` — chain helpers
