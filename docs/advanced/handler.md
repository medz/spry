---
title: Advanced → Handler
---

# Handler

`Handler` is the core concept in Spry, but it is not unique to Spry. Because `HttpServer` in `dart:io` also handles requests through `FutureOr<dynamic> Function(HttpRequest)`.

The Handler in Spry only encapsulates its specific structure. In most cases, you do not need to implement the Handler interface or use it unless you deeply customize Spry.

## Handler interface

The Handler interface has a `T` type parameter and a `handle` method. `T` represents the return value type of the `handle` method.

```dart
class MyHandler implements Handler<String> {
    @override
    T handle(HttpRequest request) {
        return 'Hello, World!';
    }
}
```

Or use an `async` method:

```dart
class MyHandler implements Handler<String> {
    @override
    Future<T> handle(HttpRequest request) async {
        return 'Hello, World!';
    }
}
```

The type of `handle` is `FutureOr<T> Function(HttpRequest)`, which is consistent with the requirements in `dart:io`.

## Closure Handler

Closure Handler is the most common handler when registering routes, and it is also the recommended method. Usually, you can directly pass in a Closure that conforms to the `FutureOr<T> Function(HttpRequest)` type when registering a route.

```dart
router.get('/hello', (request) async {
    return 'Hello, World!';
});
```

You can use a `ClosureHandler` to wrap a Closure when you definitely think a `Handler` is needed somewhere else.

```dart
final handler = ClosureHandler((request) async {
    return 'Hello, World!';
});

app.get('/hello', handler.handle);
```

Although this may seem redundant, it makes it easier to use Handler when needed. For example, if you expect to register a route via `app.routes.addRoute`, then you need a `Handler`.

```dart
final handler = ClosureHandler((request) async {
    return 'Hello, World!';
});
final route = Route(method: "GET", segments: '/hello'.asSegements, handler: handler);

app.routes.addRoute(route);
```

These functions are reserved for users who perform in-depth customization based on Spry. Generally, you do not need to use them.
