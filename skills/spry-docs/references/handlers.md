# Spry Handler Reference

## Handler Function Pattern

Every route file exports functions named after HTTP methods:

```dart
// routes/items.dart
import 'package:spry/spry.dart';

Future<Response> get(Event event) async { /* ... */ }
Future<Response> post(Event event) async { /* ... */ }
Future<Response> put(Event event) async { /* ... */ }
Future<Response> delete(Event event) async { /* ... */ }
Future<Response> patch(Event event) async { /* ... */ }
```

## The Event Object

`Event` provides the request-scoped context:

| Property | Type | Description |
|---|---|---|
| `event.request` | `Request` | Incoming HTTP request |
| `event.params` | `RouteParams` | Route parameters from path |
| `event.url` | `Uri` | Parsed request URL |
| `event.app` | `Spry` | The Spry application instance |
| `event.locals` | `Locals` | Request-scoped key-value store |

## Reading Request Data

```dart
Future<Response> post(Event event) async {
  // JSON body
  final json = await event.request.json();

  // Form data
  final form = await event.request.formData();

  // Plain text
  final text = await event.request.text();

  // Query parameters
  final query = event.url.queryParameters;

  // Headers
  final auth = event.request.headers.get('Authorization');

  // Route params
  final id = event.params['id'];

  return Response.json({'received': true});
}
```

## Building Responses

```dart
// JSON response
return Response.json({'key': 'value'});

// Custom status
return Response.json({'error': 'not found'}, status: 404);

// Plain text
return Response.text('Hello, World!');

// Redirect
return Response.redirect('/other-page');

// Empty with status
return Response.empty(status: 204);

// Custom headers
return Response.json(data, headers: {'X-Custom': 'value'});
```

## Using defineHandler

The `defineHandler` helper provides a typed wrapper:

```dart
import 'package:spry/spry.dart';

final handler = defineHandler((event) async {
  return Response.text('Hello!');
});
```

## Error Handling in Handlers

Throw `HTTPError` for controlled error responses:

```dart
import 'package:spry/spry.dart';

Future<Response> get(Event event) async {
  final item = await findItem(event.params['id']);
  if (item == null) throw HTTPError.notFound();
  return Response.json(item);
}
```

HTTPError subclasses: `BadRequestError`, `NotFoundError`, `UnauthorizedError`, `ForbiddenError`, `InternalServerError`, etc.
