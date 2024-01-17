# Spry v3.1.2

To install Spry v3.1.2 run the following command:

```bash
dart pub add spry:3.1.2
```

Or update your `pubspec.yaml` file:

```yaml
dependencies:
  spry: ^3.1.2
```

## What's Changed

1. **BUG**: Fixed Iterable responsible cannot be correctly JSON serialized.
2. **BUG**: Fixed middleware handler not being able to call next correctly.
3. `app.group` adds closure suggested parameter name

# Spry v3.1.1

To install Spry v3.1.1 run the following command:

```bash
dart pub add spry:3.1.1
```

Or update your `pubspec.yaml` file:

```yaml
dependencies:
  spry: ^3.1.1
```

## What's Changed

1. **Bug**: Fix global middleware not being used
2. **Feature**: Support a `Iterable` of `Middleware` stack support making handler.
3. **Feature**: Public `ClosureHandler` class.

# Spry 3.1.0

To install Spry 3.1.0 run the following command:

```bash
dart pub add spry
```

Or update your `pubspec.yaml` file:

```yaml
dependencies:
  spry: ^3.1.0
```

## What's Changed

1. **Feature**: `Application` support late initialization HTTP server
2. **Feature**: `Application` support with HTTP server factory.
3. **Docs**: Add `Application` document.
4. **Bug**: Fix `addRoute` without parameter signature of `T` type.
5. **Feature**: Support web socket.
6. **Docs**: Add web socket document.

# Spry 3.0.0

To install Spry 3.0.0 run the following command:

```bash
dart pub add spry
```

Or update your `pubspec.yaml` file:

```yaml
dependencies:
  spry: ^3.0.0
```

## What's Changed

1. **Breaking Change**: Rewrite the entire design of the framework, and the API is completely different from the previous version.
2. Cancel the request dialect and use `HttpRequest` of `dart:io`
3. Cancel the response dialect and use `HttpResponse` of `dart:io`
4. perform magic on the `HttpRequest` and `HttpResponse` objects to make them easier to use and more powerful
5. Better performing router
6. Let you learn less, you only need to know `dart:io`
