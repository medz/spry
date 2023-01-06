## 0.1.1

### Param Middleware

Param middleware now supports `use` method to add middleware to a specific param.

```dart
final ParamMiddleware middleware.use(otherMiddleware);
```

### Handler extension

Spry handler supported `use` and `param` methods to add middleware and param middleware to a handler.

```dart
final Handler handler.use(middleware).param(paramMiddleware);
```

## 0.1.0

1. Update `spry` to `0.1.3`.
2. Fix docs typo.
3. **BREAKING CHANGE**: `ParamMiddlewareNext` is now `ParamNext`.

## 0.0.3

1. Hidden `RouterImpl` class.
2. Not found default changed to `HttpException.notFound()`.

## 0.0.2

Update deps.

## 0.0.1

Spry makes it easy to build web applications and API applications in Dart with middleware composition processors. This package provides Spry with request routing handlers that dispatch requests to handlers by routing matching patterns.
