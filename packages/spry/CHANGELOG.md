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
