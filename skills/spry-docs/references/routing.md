# Spry Routing Reference

## Expressive Segment Syntax

Spry supports a rich set of expressive path segments:

| Syntax | Example | Matches |
|---|---|---|
| Literal | `users` | Exact segment match |
| Named param | `[id]` | Single segment, captured as `id` |
| Regex param | `[id=\d+]` | Single segment matching `\d+` |
| Optional param | `[[lang]]` | Zero or one segment |
| Repeated param | `[...slug]` | Zero or more segments (wildcard) |
| Single wildcard | `[*]` | Exactly one segment (any value) |

## Path Pattern Examples

| File | Path Pattern | Matched URLs |
|---|---|---|
| `routes/index.dart` | `/` | `/` |
| `routes/about.dart` | `/about` | `/about` |
| `routes/users/[id].dart` | `/users/:id` | `/users/42`, `/users/alice` |
| `routes/posts/[id=\d+].dart` | `/posts/:id{\d+}` | `/posts/123` (not `/posts/abc`) |
| `routes/docs/[[...slug]].dart` | `/docs/**:slug` | `/docs`, `/docs/a`, `/docs/a/b` |
| `routes/[...catchall].dart` | `/:catchall` | `/any`, `/any/path/here` |

## Method-Specific Routing

Route files can be suffixed with an HTTP method to restrict matching:

- `routes/users.get.dart` → `GET /users` only
- `routes/users.post.dart` → `POST /users` only
- `routes/users.dart` → All HTTP methods

Supported method suffixes: `.get`, `.post`, `.put`, `.delete`, `.patch`, `.head`, `.options`.

## Route Handlers

Each route file exports handler functions named after the HTTP method they handle:

```dart
// routes/users/[id].dart
import 'package:spry/spry.dart';

Future<Response> get(Event event) async {
  final id = event.params['id'];
  return Response.json({'user': id});
}

Future<Response> post(Event event) async {
  final body = await event.request.json();
  return Response.json(body, status: 201);
}
```

### Fallback Handlers

The fallback map in `routes/index.dart` catches requests that don't match any route:

```dart
final fallback = {
  null: (Event e) async => Response.notFound(),
};
```

## Route Parameters

Access route parameters via `event.params`:

```dart
// routes/users/[id]/posts/[pid].dart
Future<Response> get(Event event) async {
  final userId = event.params['id'];    // from [id]
  final postId = event.params['pid'];   // from [pid]
  // ...
}
```

## Case Sensitivity

Route matching is case-sensitive by default. Set `caseSensitive: false` in `spry.config.dart` for case-insensitive matching.
