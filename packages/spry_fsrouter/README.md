# Filesystem router for [Spry](https://spry.fun)

Define Spry router in the way of filesystem router layout, it builds on top of [spry_router](https://pub.dev/packages/spry_router), supports group route mount, nested route, handler mount, middleware, etc.

## Installation

Add `spry_fsrouter` to your `pubspec.yaml` file:

```yaml
dependencies:
  spry_fsrouter: any
```

Or install it from the command line:

```bash
dart pub add spry_fsrouter
```

## The `app` Directory

The directory where the router is located, which is also the directory where the generated route definitions are located. is the only place you import router handler.

It is `lib/app` relative to where your project is located, and the `app` directory will contain all your middleware and handlers.

## directories and files inside `app`

In the `app` directory:

1. Directories are used to define routes. A route is a single route of nested directories, following a hierarchy from the root directory to subdirectories.
2. Files are used to create middleware, handlers, etc., see [Special Files](#special-files).

## Route Segments

Each directory is a route segment, and the name of the directory is the name of the route segment.

```text
        app/
         ├── api/
         │   ├── users/
         │   │     │
spry.fun[/][api]/[users]
╰──────────URL─────────╯
```

## Nested Routes

To create a nested route, you can nest folders inside each other. For example, you can add a new `/api/users` route by nesting two new folders in the `app` directory.

The `/api/users` route is composed of three segments:

- `/` Root segment
- `api` Segment
- `users` Segment

## Special Files

Spry filesystem router provides a set of special files that you can use in your routes. These files are:

- `handler.dart` - A handler file, which needs to expose a variable or function named `handler`.
- `middleware.dart` - A middleware file, which needs to expose a variable or function named `middleware`.
- `{name}.middleware.dart` - The parameter middleware file, which needs to provide a standard Spry router parameter middleware named `middleware`.
- `404.dart` - The 404 handler file, which needs to expose a variable or function named `handler`.
- `segment.yaml` - Configure the current route segment.

## Colocation

Under normal circumstances, all routing segments follow the directory nesting rules to generate paths, for example: `lib/app/api/users` will produce `/api/users` and mount `/lib/app/api/users/handler.dart ` to the root router.

Sometimes we expect `/api/*` to be an independent collection, create an independent router and then mount it on the root router.

You can create a `segment.yaml` file, define a variable named `colocation` and set it to `true`:

```yaml
# lib/app/api/segment.yaml
colocation: true
```

## Creating Routes

Inside the `app` directory, **Directories** are used to define routes.

Each directory is a **route segment** that maps to a **URL** segment. to create a nested route, you can nest folders inside each other.

```text
        app/
         ├── api/
         │   ├── users/
         │   │     │
spry.fun[/][api]/[users]
╰──────────URL─────────╯
```

A special `handler.dart` file is used to make route segments publicly accessible.

```text
app/
  ├── all.dart    => /
  ├── api/
      ├── handler.dart => /api
```

## Creating Middleware

A special `middleware.dart` file is used to create middleware.

```text
app/
  ├── middleware.dart    => /
  ├── api/
      ├── middleware.dart => /api
```
```dart
// app/middleware.dart
import 'package:spry/spry.dart';

Future<void> middleware(Context context, Next next) async {
  // Before do something
  await next();
  // After do something
}
```

If you need to create a parameter middleware, you can create a file named `{name}.middleware.dart`, and the middleware function needs to be named `middleware`.

```text
https://spry.fun/api/users/123
╰───URL────────╯╰──Segment──╯

app/
  ├── api/
      ├── [id].middleware.dart => /api/:id
```
```dart
// app/api/id.middleware.dart
import 'package:spry/spry.dart';

Future<void> middleware(Context context, Object? value, ParamNext next) async {
  final parsedValue = ... // Parse the value
  await next(parsedValue);
}
```

## Dynamic Segments

Dynamic segments are segments that can match any URL path segment. They are defined by wrapping the segment name in square brackets (`[]`).

```text
        app/
         ├── api/
         │   ├── [id]/
         │   │     │
spry.fun[/][api]/[:id]
╰──────────URL────────╯
```

### Define a dynamic segment expression

You can define a dynamic segment expression, which is a [Prexp](https://github.com/odroe/prexp) expression that matches the segment value.

Create a `segment.yaml` file in the directory, and define a variable named `expression`:

```text
        app/
         ├── api/
         │   ├── [id]/
         │   │     │
spry.fun[/][api]/[:id(\d+)]
╰──────────URL────────╯
```
```yaml
# app/api/[id]/segment.yaml
expression: '(\d+)'
```

Now, the `id` segment can only match a number.

## Not Found

If you want to define a 404 page, you can create a `404.dart` file in the `app` directory.

```text
        app/
         ├── 404.dart
         │
spry.fun[/]{Any not defined segment}
╰──────────URL────────╯
```

The `404.dart` file needs to expose a variable or function named `handler`.

```dart
// app/404.dart
import 'package:spry/spry.dart';

Future<void> handler(Context context) async {
  context.response.statusCode = 404;
  context.response.send('404 Not Found');
}
```

## Defining HTTP verb

You can define the HTTP verb of the route by defining a `(verb)/` directory.

The `app/handler.dart` file will be mounted to the `all` verb.

Define a `(get)/` directory, the `app/(get)/handler.dart` file will be mounted to the `get` verb.

```text
        app/
         ├── (get)/
         │   ├── handler.dart
         │   │
spry.fun[/]{GET}

> If you don't define the HTTP verb, the default is `all`.

## Generating root router

Before using the router, you need to run additional commands to generate the final router instance.

```bash
$ dart run spry_fsrouter
```

This command will generate a `lib/app/app.dart` file, which is the root router instance.

The `lib/app/app.dart` exports the root router instance, and you can use it in your application.

```dart
import 'package:spry/spry.dart';
import 'package:your_app/app/app.dart';

void main() async {
  final Spry spry = Spry();

  // Do something

  await spry.listen(app, port: 3000);
  print('Listening on http://localhost:3000');
}
```

## API Reference

Read the [API Reference](https://pub.dev/documentation/spry_fsrouter) for more information.
