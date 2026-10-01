# Spry Handler Reference

## Handler Function Pattern

Each route file exports `handler`. Use a filename suffix such as `items.get.dart` to restrict its method:

```dart
// routes/items.dart
import 'package:spry/spry.dart';

Response handler(Event event) => Response.json({'ok': true});
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
Future<Response> handler(Event event) async {
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
return Response.json({'error': 'not found'}, ResponseInit(status: 404));

// Plain text
return Response('Hello, World!');

// Redirect
return Response.redirect(Uri.parse('/other-page'));

// Empty with status
return Response(null, ResponseInit(status: 204));

// Custom headers
return Response.json(data, ResponseInit(headers: {'X-Custom': 'value'}));
```

## Using defineHandler

The `defineHandler` helper provides a typed wrapper:

```dart
import 'package:spry/spry.dart';

final handler = defineHandler((event) async {
  return Response('Hello!');
});
```

## Error Handling in Handlers

Throw `HTTPError` for controlled error responses:

```dart
import 'package:spry/spry.dart';

Future<Response> handler(Event event) async {
  final item = await findItem(event.params['id']);
  if (item == null) throw HTTPError(404);
  return Response.json(item);
}
```

`HTTPError(status, body: ..., headers: ...)` handles explicit HTTP failures. Spry throws `NotFoundError(method: ..., path: ...)` for unmatched requests.

Scoped `_error.dart` files export `onError`:

```dart
import 'package:spry/spry.dart';

Response onError(Object error, StackTrace stackTrace, Event event) =>
    Response('Error', ResponseInit(status: 500));
```
