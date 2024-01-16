---
title: Advanced → Application
---

# Application

Application is the cornerstone of Spry, it carries all the magic of Spry!

## Create With HTTP Server (Recommended)

The recommended way to create a Spry Application is to pass it any concrete implementation of `HttpServer` in `dart:io`.

```dart
import 'dart:io';

main() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 3000);
    final app = Application(server);
}
```

::: tip

If you want to use `bindSecure` to create an HTTPS server, you must create the Application this way.

:::

## Simple Create

You can also create a simple `HttpServer` server through `Application.create` and bind it to the Spry Application.

```dart
import 'package:spry/spry.dart';

main() async {
    final app = await Application.create(port: 3000);
}
```

`port` is required and is used to specify the port that the server listens on. It also has some optional parameters:

| Argument  | Type      | Default                        | Description                |
| --------- | --------- | ------------------------------ | -------------------------- |
| `address` | `dynamic` | `InternetAddress.loopbackIPv4` | HTTP Server listen address |
| `port`    | `int`     | -                              | HTTP Server listen port    |
| `backlog` | `int`     | `0`                            | HTTP Server backlog        |
| `shared`  | `bool`    | `false`                        | HTTP Server shared         |
| `v6Only`  | `bool`    | `false`                        | HTTP Server v6Only         |

## Late Initialization

You can also create an Application that lazily initializes the HTTP Server through `Application.late`. This method allows you to create the Application in a separate file and lazily create the HTTP Server when your application is running.

```dart
import 'package:spry/spry.dart';

final app = Application.late();
```

::: danger

Applications that delay the creation of HTTP Server cannot call the `app.listen` method to listen for requests. You must use the `app.run` method to start the Application.

```dart
final app = Application.late();

main() async {
    app.get("hello", (request) => "Hello, Spry!");

    await app.run(port: 3000); // [!code focus]
}
```

:::

## Create with HTTP Server Factory

In addition to using `Application.late` to create Application statically, you can also use HTTP Server factory to create Application through `Application.factory`.

```dart
import 'dart:io';

Future<HttpServer> serverFactory(Application app) async {
    ...
}

final app = Application.factory(serverFactory);
```

The factory's type signature is `FutureOr<HttpServer> Function(Application)`, which receives an Application instance and returns a `Future<HttpServer>` or `HttpServer` instance.

This approach is particularly useful if you are mixing multiple frameworks or if you need to defer creating an HTTP server based on configuration.

::: warning

The Application instance accepted by the HTTP Server factory does not yet contain `server` information. You cannot get it because it is a property of the `late final` signature, and you cannot set it. To properly set the Application's `server` property, you can only return an `HttpServer` instance from the factory.

:::

## Listen requests

You can enable request monitoring through `app.listen`.

::: warning

Note that if you use `Application.late` to create the Application, you cannot use `app.listen` to listen for requests. You must use the `app.run` method to start the Application.

:::

## Run Application

It is a unique method that only serves the Application created by `Application.late`. It will create an HTTP Server and listen for requests while your application is running.

```dart
final app = Application.late();

main() async {
    app.get("hello", (request) => "Hello, Spry!");

    await app.run(port: 3000); // [!code focus]
}
```

## Handle Requests

When you need to customize sending requests instead of Spry listening for requests autonomously, you can obtain Spry's request processing entry through `app.handler`.

It is an instance that implements the `Handler` interface and is usually useful when testing or when you handle HTTP Server listen yourself.

```dart
main () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 3000);
    final app = Application(server);

    app.get("hello", (request) => "Hello, Spry!");

    await (final request in server) {
        if (request.method == 'post') {
            // You can customize your request here
        }

        // Or otherwise, you can use Spry handler
        await app.handler.handle(request);
    }
}
```
