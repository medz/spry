## 0.3.1

Fix the `mount` not inject route params bug.

## 0.3.0

### BREAKING CHANGE

#### Router Prefix

The `Router` class not longer has the `prefix` property.

```dart
// Before
final router = Router('/api');

// Now
final router = Router();
```

#### Router Mount

Proxy forwarding a prefixed request to the unified handler/router via `mount`. Previously, it could only be forwarded to the handler, but now it supports forwarding to the router.

```dart
// Before
router.mount('/api', handler);

// Now
router.mount('/api', handler: handler);
router.mount('/api', router: router);
```

### New Features

#### Merge Router

The `Router` class now supports merging multiple routers into one.

```dart
final router = Router();
router.merge(router1);
router.merge(router2);
```

#### Router handle

Previously, Router could only be used as a standard Spry handler, which caused many problems, such as path matching not working properly, or prefix requiring a root-based path!

Now, no more, we added the handle method to satisfy the above customization process.

### Nesting Router

Nested routers are now supported, and the routes are independent, and they can be nested for merging, mounting, and other operations:

```dart
final r1 = Router();
final r2 = Router();

r1.mount('r2', router: r2);
r2.mount('r1', router: r1);

r1.merge(r2);
r2.merge(r1);

r1.mount('r1', router: r1);
r2.mount('r2', router: r2);

r1.merge(r1);
r2.merge(r2);
```

Yes, you read that right, Routers can mount and merge with each other!

By mounting each other, you can create a routing path that repeats path segments infinitely long! But that's not what this feature wants you to accomplish, what we added this feature is to allow you to modularize your Spry program, and then support whatever prefix path you want to mount that module on!

## 0.2.0

1. **BREAKING CHANGE**: `mount` now needs a `prefix` argument.
2. `Router` public the property `prefix`.

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
