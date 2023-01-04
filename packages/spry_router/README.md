# Spry Router

Spry makes it easy to build web applications and API applications in Dart with middleware composition processors. This package provides Spry with request routing handlers that dispatch requests to handlers by routing matching patterns.

[![pub package](https://img.shields.io/pub/v/spry_router.svg)](https://pub.dartlang.org/packages/spry_router)

## Installation

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  spry_router: any
```

Or install it from the command line:

```bash
$ dart pub add spry_router
```

## Example

```dart
import 'package:spry/spry.dart';
import 'package:spry_router/spry_router.dart';

void main() async {
  final spry = Spry();
  final router = Router();

  router.get('/hello', (Context context) {
    context.response.send('Hello World!');
  });

  await spry.listen(router, port: 3000);

  print('Server running on port 3000');
}
```

## Handler

The Spry router is a standard Spry processor that takes a `Context` object as a parameter and returns a `void` object.

The router can be passed directly as a handler through `spry.listen`.

```dart
spry.listen(router, port: 3000);
```

It is also possible to create a standard HttpServer handler via `spry.call`.

```dart
final handler = await spry(router);

final server = await HttpServer.bind('localhost', 3000);
server.listen(handler);
```

## Path expression

In Spry, route matching is achieved through path expressions, which are strings that can contain the following:

- String
- Parameter
- Wildcard
- Regular expression

### String

A string is the simplest path expression, it's just an ordinary string, for example:

```dart
router.get('/hello', (Context context) {
   context.response.send('Hello World!');
});
```

### Parameter

The parameter is a special string that can match any string, but it will pass the matched string as a parameter to the processor, for example:

```dart
router.get('/hello/:name', (Context context) {
   context.response.send('Hello ${context.request.params['name']}!');
});
```

### Wildcard

A wildcard is a special string that can match any string, but it will not pass the matched string as a parameter to the processor, for example:

```dart
router.get('/hello/*', (Context context) {
   context.response.send('Hello World!');
});
```
The > represents any string, for example `/hello/world`, `/hello/123`, `/hello/abc` can all be matched.

### Regular expression

A regular expression is a special string that can match any string, but it will not pass the matched string as a parameter to the processor, for example:

```dart
router.get(RegExp(r'/hello/\d+'), (Context context) {
   context.response.send('Hello World!');
});
```

> The path expressions of Spry router are implemented through [Prexp](https://github.com/odroe/prexp), so all path expressions supported by Preexp are supported.
>
> To know more about the usage of Preexp, please refer to [Prexp](https://github.com/odroe/prexp).

## HTTP methods

Spry supports [all registered Http methods](https://www.iana.org/assignments/http-methods/http-methods.txt), i.e. in [HTTP/1.1](https://tools.ietf. org/html/rfc2616) all methods defined in .

> Also supports `all` method, which can match all Http methods.

```dart
router.route('get', '/hello', (Context context) {
   context.response.send('Hello World!');
});
```

Of course, every time you register a route through the `route` method, you need to specify the Http method, which will be very cumbersome, so Spry provides some shortcut methods, such as `all`, `get`, `post`, `put` , `delete`, `head`, `options`, `patch`, `trace`.

## Middleware

Spry router supports standard Spry middleware, which can be registered through `use` method.

```dart
router.use((Context context, Next next) async {
   print('Before');
   await next();
   print('After');
});
```

### Routing group middleware

In addition to being a standard Spry handler, each `Router` object is also a routing group, so middleware can be registered through the `use` method.

```dart
router.use((Context context, Next next) async {
   print('Before');
   await next();
   print('After');
});
```

For middleware registered through the `use` method, all routes under this `Router` object will take effect.

### Routing middleware

Routes registered through the `route` method or routes registered through the shortcut method can register middleware through the `use` method.

```dart
final hello = router.route('get', '/hello', (Context context) {
   context.response.send('Hello World!');
});

hello.use((Context context, Next next) async {
   print('Before');
   await next();
   print('After');
});
```

The middleware registered in this way will only take effect under the `/hello` route.

### Parameter middleware

When defining a routing group/routing, we may need to do some processing on the parameters before entering the processor, for example:

```dart
router.get('/hello/:name', (Context context) {
   context.response.send('Hello ${context.request.params['name']}!');
});
```

For the route defined in this way, we can get the `name` parameter through `context.request.params`, but if we need to do some processing on the `name` parameter, such as converting it to uppercase, then we can pass `param` method to register a parametric middleware.

```dart
router.param('name', (Context context, Object? value, ParamNext next) async {
   final String toUpper = value.toString().toUpperCase();
   await next(toUpper);
});
```

Thus, when we visit `/hello/spry`, the value of `context.request.params['name']` is `SPRY`.

> The `Route` object also supports the `param` method, and its usage is consistent with the `param` method of the `Router` object.

## Routing group nesting

Through the `mount` method, we can mount a `Router` object under another `Router` object.

```dart
final api = Router('/api');

api.get('/users/:name', (Context context) {
   context.response.send('User ${context.request.params['id']}');
});

router.mount(api);
```

In this way, we have mounted a routing group to `/api`, and when we visit `/api/users/spry`, it will return `User spry`.

## prefix handler

In addition to using the `mount` method to mount the routing group, we can also pass a Spry handler and `prefix` parameters to mount the routing prefix handler.

```dart
router.mount(prefix: '/api', (Context context) {
   // Do something
});
```

This is equivalent to:

```dart
router.all('/api/*', (Context context) {
   // Do something
});
```

## Get routing parameters

In the route handler, we can get route parameters through `context.request.params`.

```dart
router.get('/hello/:name', (Context context) {
   context.response.send('Hello ${context.request.params['name']}!');
});
```

Of course, we can also get routing parameters through `context.request.param` method.

```dart
router.get('/hello/:name', (Context context) {
   context.response.send('Hello ${context.request.param('name')}!');
});
```