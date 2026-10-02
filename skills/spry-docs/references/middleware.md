# Spry Middleware Reference

## Middleware Function Signature

```dart
import 'package:spry/spry.dart';

Future<Response> middleware(Event event, Next next) async {
  // Before: inspect/modify request
  final response = await next();
  // After: inspect/modify response
  return response;
}
```

Call `next()` to pass control to the next layer. Return a `Response` directly to short-circuit the chain.

## Global Middleware

Place files in `middleware/` at the project root. Each file exports a function named `middleware`:

```dart
// middleware/logger.dart
import 'package:spry/spry.dart';

Future<Response> middleware(Event event, Next next) async {
  final start = DateTime.now();
  final response = await next();
  print('${event.request.method} ${event.url.path} '
        '${response.status} ${DateTime.now().difference(start)}');
  return response;
}
```

Global middleware applies after the public asset check. Successful static GET and HEAD responses return before global or scoped middleware runs.

## Scoped Middleware

Place `_middleware.dart` files inside `routes/` directories:

```text
routes/
  _middleware.dart       # applies to all routes
  admin/
    _middleware.dart     # applies to /admin/** only
    dashboard.dart
```

Global middleware runs before scoped middleware. Within scopes, broader scopes run before more specific ones.

## Method-Specific Middleware

Suffix middleware files to restrict by HTTP method:

- `middleware/auth.post.dart` — only for POST requests globally
- `routes/admin/_middleware.get.dart` — only for GET requests in `/admin/**`

## Middleware Execution Order

For a request to `GET /admin/users`:

1. `middleware/*.dart` files (global, filename order)
2. `routes/_middleware.dart` (scoped, less specific)
3. `routes/admin/_middleware.dart` (scoped, most specific)
4. Route handler for `/admin/users`

## Combining Middleware

Import the first-party helpers from `package:spry/middleware.dart`:

```dart
import 'package:spry/middleware.dart';

final middleware = every([requestId(), timing()]);
```

`every` runs all middleware in order. `except` skips selected paths; `some` provides fallback candidates with explicit error handling. See the package middleware guide for their options.
