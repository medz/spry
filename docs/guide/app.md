---
title: Basics → App (Spry)
---

# App (Spry)

The heart of Spry is the `app` instance. It is the core handler for incoming requests. You can use the application instance to register event handlers.

## Initialize the application

You can use the default factory of `Spry` to create a new Spry application instance:

```dart
final app = Spry();
```

There are some additional options supported when initializing the application:

### `locals`

`locals` is an initialization data with a `Map` type, which defaults to `null`. It exists to hold the instance of the entire App extension function. When your application has written extension functions locally and needs to be initialized for global sharing, setting it is very useful.

When the initialization of App is completed, it will be converted to a `Locals` object. Here is a simple demonstration of globally shared data:

```dart
final app = Spry(locals: {
    'name': 'Seven',
});

final app.use((event) {
    print(event.locals.get('nane')); // Seven

    return next();
});
```

### `router`

Spry uses the Radix-Tree router implemented in [RoutingKit](https://pub.dev/packages/routingkit) by default. You can also implement your own Router for Spry to use. Just make it satisfy the `Router<Handler>` signature:

```dart
import 'package:routingkit/routingkit.dart';

class MyRouter implements Router<Handler> {
    ...
}

final app = Spry(router: MyRouter());
```

### `routerDriver`

This is a custom Router implementation provided by [RoutingKit](https://pub.dev/packages/routingkit). When you pass it to Spry when using other RoutingKit directories, Spry will use this driver to create Router instances.

### `caseSensitive`

This option tells Router whether to distinguish between upper and lower case paths. The default is `false` (ignore case). If you use Spry for other scenarios, you may need it.

```dart
final app = Spry(caseSensitive: false);
```

## Adding Routes

`addRoute` is the basic method for the entire Core to implement and add routing handlers:

```dart
app.addRoute(<METHOD>, <PATH>, <Handler>);
```

::: tip
For more information, please see [Basics → Routing](/guide/routing)
:::

## Adding Handlers

Spry is capable of stack (Onion, growing from the inside out) processing. Each time `addHandler` is used, it will be added to the innermost layer of the nested layer. When calling, use them one by one in the order of addition.

```dart
app.addHandler(ClosureHandler((event) => ...));
```

Each added layer has the ability to return `Response` independently. This will result in that if a layer directly returns a `Response` object, the later added layer will not be called.
Of course, this is intentional, just like peeling an onion, we only need to peel specific layers, and there is no need to peel the onion layer by layer.

If a layer wants to call the following layer, it needs to use `next` to implement it:

```dart
MyHandler implements Handler {
    Future<Response> handle(Event event) async {
        print('Before');
        final res = await next(event);
        print('After');

        return res;
    }
}
```

## `.use(...)`

`addHandler` is a low API, it is not easy to use. So you can use `use` in Spry to quickly add a Handler without implementing the `Handler` interface:

```dart
app.use((Event event) {
    print('Hi');

    return next(event);
});
```

## Fallback

After we run the Spry server, there is always a possibility of encountering a route that is not registered. Spry uses a `404` response by default. If you want to customize the implementation of a Handler that cannot find the path, please use `fallback`:

```dart
app.fallback((event) => 404);
```
