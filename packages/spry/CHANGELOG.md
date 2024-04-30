# Spry v3.3.0

To install Spry v3.3.0 run the following command:

```bash
dart pub add spry:3.3.0
```

or update your `pubspec.yaml` file:

```yaml
dependencies:
  spry: ^3.3.0
```

## What's Changed

- **Feature**: Support `request.fetch`, see `webfetch` fetch function.

# Spry v3.2.3

To install Spry v3.2.3 run the following command:

```bash
dart pub add spry:3.2.3
```

Or update your `pubspec.yaml` file:

```yaml
dependencies:
  spry: ^3.2.3
```

## What's Changed

- fix `request.json()` being incorrectly set to not lock (`false`).

# Spry v3.2.2

To install Spry v3.2.2 run the following command:

```bash
dart pub add spry:3.2.2
```

Or update your `pubspec.yaml` file:

```yaml
dependencies:
  spry: ^3.2.2
```

## What's Changed

- fix response not using encoding
- fix `FormData` response charset
- `Responsesible` support `HttpClientResponse` of `dart:io`
- `Responsesible` support `HttpResponse` of `dart:io`
- `Responsesible` support `TypedData`

# Spry v3.2.1

To install Spry v3.2.1 run the following command:

```bash
dart pub add spry:3.2.1
```

Or update your `pubspec.yaml` file:

```yaml
dependencies:
  spry: ^3.2.1
```

## What's Changed

1. fix type version information

# Spry v3.2.0

To install Spry v3.2.0 run the following command:

```bash
dart pub add spry:3.2.0
```

Or update your `pubspec.yaml` file:

```yaml
dependencies:
  spry: ^3.2.0
```

## What's Changed

1. **Docs**: fix `route.path` to `route.segments`, Thanks [@utamori](https://github.com/utamori)
2. **Feature**: Support `RethrowEception`, Catch exception to next filter process
3. **Feature**: `request.json` supports implicit type conversion
4. **Feature**: Added built-in `Blob` export
5. **Feature**: Support closure-style middleware
6. **Feature**: Support custom `x-powered-by` header value in `app.poweredBy`

## Credits

- @utamori - [GitHub Profile](https://github.com/utamori)

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
