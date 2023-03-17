# Changelog

## [1.1.0](https://github.com/odroe/spry/compare/spry_router-v1.0.0...spry_router-v1.1.0) (2023-03-17)


### Features

* Adapt to spry 1.0 ([6b4c18d](https://github.com/odroe/spry/commit/6b4c18de76d08ea2b41b7bced97c7541e5da2bca))
* Adapt to spry 1.0 ([e1a8b70](https://github.com/odroe/spry/commit/e1a8b70fe0a810912bd7432c2e2d9cd782298354))

## [1.0.0](https://github.com/odroe/spry/compare/spry_router-v0.5.0...spry_router-v1.0.0) (2023-03-15)


### ⚠ BREAKING CHANGES

* Fix wrong version dependencies

### Bug Fixes

* Fix wrong version dependencies ([e65b8d3](https://github.com/odroe/spry/commit/e65b8d3185dd63e5fc99e6292fe6497e8ff9a8a1))

## [0.5.0](https://github.com/odroe/spry/compare/spry_router-v0.4.1...spry_router-v0.5.0) (2023-03-14)


### Features

* Add use and param extension for middleware and handler ([54a2379](https://github.com/odroe/spry/commit/54a2379f8539f6db673b873e81e598e9b2239fb9))
* MiddlewareNext -&gt; Next ([80b3da7](https://github.com/odroe/spry/commit/80b3da7927ad855032c8f3af2d965db5b2217c5f))
* **router:** Allow duplicate routes to be added to the router ([d08f181](https://github.com/odroe/spry/commit/d08f181329dff0106c4de7ec248e0c34af1ae223))


### Bug Fixes

* **spry_router:** Fix the `mount` not inject route params bug. ([8f5c314](https://github.com/odroe/spry/commit/8f5c314f64e4da7a85eee836465cf87a01462b1a))

## 0.4.1

Update readme.

## 0.4.0

Adapt to the new `spry` 0.4.0 version.

## 0.3.2

Allow duplicate routes to be added to the router.

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
