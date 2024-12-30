---
title: Guide → Handler
description: Event handler define application logic.
---

# Handler

{{ $frontmatter.description }}

---

After creating an [app instance](/guide/app), you can start defining your application logic using event handlers.
An event handler is a function that receive an Event instance and returns a response. You can compare it to controllers in other frameworks.

## Defining event handlers

To define an event handler you just need to create a function that accepts an [`Event` object](/guide/event) and can return anything:

```dart
String handler(Event event) {
    return 'Response';
}
```

The callback function can be sync or async:

```dart
Future<String> handler(Event event) async {
    return 'Response';
}
```

## Responses Types

Values returned from event handlers are automatically converted to responses. It can be:

* You can return an arbitrary object (e.g. `Map`, `List`) or an object with a `toJson()` method, it will be stringified and sent with default `application/json` content-type.
* `String`/`num`/`bool` - Sent as-is using default `text/plain` content-type.
* `null`/`void` - Spry with end response with `204 - No Content` status code.
* `Response`
* `Stream<Uint8List>`

Any of above values could also be wrapped in a `FutureOr`. This means that you can return a `FutureOr` from your event handler and Spry will wait for it to resolve before sending the response.

## Middleware

```dart
app.use((event, next) {
    final res = next(event);
    print('after');

    return res;
});
```
