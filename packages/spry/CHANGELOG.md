# Changelog

## [2.0.0](https://github.com/odroe/spry/compare/spry-v1.0.0...spry-v2.0.0) (2023-03-17)


### ⚠ BREAKING CHANGES

* Move spry multer in framework, migration guide:
* Move spry multer in framework, migration guide: ```diff
    - import "package:spry_multer/spry_multer.dart";
    + import "package:spry/multer.dart";
    ```
* Move the `spry_json` into `spry`: ```diff
    - import "package:spry_json/spry_json.dart";
    + import "package:spry/json.dart";
    ...
    - final json = SpryJson(...);
    - spry.use(json);
* Move spry session in framework, mgration guide: ```diff
    - import "package:spry_session/spry_session.dart";
    + import "package:spry/session.dart";
    ```
* Remove `package:spry_urlencoded/spry_urlencoded.dart`, moved into `package:spry/urlencoded.dart`.
    #### Migration guide
    ```diff
    - import "package:spry_urlencoded/spry_urlencoded.dart"
    + import "package:spry/urlencoded.dart"
    ```

### Features

* merge `spry_urlencoded` into `spry` package ([d62f6f3](https://github.com/odroe/spry/commit/d62f6f3eaccde36716a236df0b35dd3257ebf0b0))


### Code Refactoring

* Move json into spry ([d73b978](https://github.com/odroe/spry/commit/d73b9787b9a9b7fd9ec9c87732dc0fc2dc89eed6))
* Move spry interceptor in framework ([b7361c7](https://github.com/odroe/spry/commit/b7361c72a94a423ec0a715f2349f2ad6f8210ef8))
* Move spry multer in framework ([70b2884](https://github.com/odroe/spry/commit/70b2884037a0730225e85c49bcdab6c1c0edf2c4))
* Move spry session in framework ([a264f99](https://github.com/odroe/spry/commit/a264f999db88ba26a57dc9dedb47f8da3d5485a2))

## [1.0.0](https://github.com/odroe/spry/compare/spry-v0.5.0...spry-v1.0.0) (2023-03-17)


### ⚠ BREAKING CHANGES

* Refactor spry core impl

### Bug Fixes

* Deprecated constants ([06f2e63](https://github.com/odroe/spry/commit/06f2e63bea23ae7eddb021275b6e8c95bf7eed21))
* Fix late context in request/response ([f5a6a19](https://github.com/odroe/spry/commit/f5a6a19e31ea5d70ebb797091a3a75f45a85f1d0))


### Code Refactoring

* Refactor spry core impl ([724ac31](https://github.com/odroe/spry/commit/724ac3181a2dec1c907a44675b241d79d1bd7b20))

## [0.5.0](https://github.com/odroe/spry/compare/spry-v0.4.1...spry-v0.5.0) (2023-03-14)


### Features

* MiddlewareNext -&gt; Next ([80b3da7](https://github.com/odroe/spry/commit/80b3da7927ad855032c8f3af2d965db5b2217c5f))
* **spry:** Add `redirect` and `close` method in response ([d6cb359](https://github.com/odroe/spry/commit/d6cb3594ed8e9f0bcf7f8abcce840feae3872c96))
* **spry:** Add get spry app in context extension ([08fc0d5](https://github.com/odroe/spry/commit/08fc0d5ccd63b0444ae5320b1eefac85e12c6430))
* **spry:** Export `ContextImpl` to `package:spry/impl.dart`. ([ef14385](https://github.com/odroe/spry/commit/ef1438599f2e9716298d2101648df6f4d0338a4e))
* **spry:** Request add `stream` and `text` method ([048e989](https://github.com/odroe/spry/commit/048e9899ce8beecd699a61636cee06136e08d54d))
* **spry:** request/response text encoding set in global ([2e0eadb](https://github.com/odroe/spry/commit/2e0eadb432538b75c67a7d4726fca88643c08373))
* **spry:** Store spry application in context. ([2ecbab3](https://github.com/odroe/spry/commit/2ecbab3a4d77f43982299faee1abbdb9d9e846d9))


### Bug Fixes

* **spry:** Fix eager close response not written to body ([bff8774](https://github.com/odroe/spry/commit/bff877427792098eeb15c69e5ec636b2ce0a2d22))
* **spry:** Fix no tag to close response after redirection ([250483d](https://github.com/odroe/spry/commit/250483d3b5abddd947ba14db46e1bacbff535e56)), closes [#28](https://github.com/odroe/spry/issues/28)
* **spry:** Fix the `HttpException` is not exported. ([5f8f90c](https://github.com/odroe/spry/commit/5f8f90c6d877eebf899f1bb73d4811fa9608950f))

## 0.4.1

### Bug fixes

- Fix `HttpException.badRequest` status code is 400.

## 0.4.0

### Breaking changes

1. `package://spry/extension.dart` changed to `package://spry/extensions.dart`.
2. Remove `Response.send` method.
3. Remove `Response.isBodyReady` property.
4. Remove `Response` encoding parameter.
5. Add write a `Stream<List<int>>` to the response body method `Response.stream`.
6. Add write a `String` to the response body method `Response.text`.
7. Add write a `List<int>` to the response body method `Response.raw`.
8. Add read the request body as a `Stream<List<int>>` method `Request.stream()`.
9. Add read the request body as a `String` method `Request.text()`.
10. Request/Response global encoding in `Spry` instance.

## 0.3.0

### Breaking changes

`request.raw` getter changed to `request.raw()`

## 0.2.0

### Breaking changes

`request.body` is changed to `request.raw`.

## 0.1.4

1. Fix eager close response not written to body.

## 0.1.3

1. Store spry application in context.
2. Export `ContextImpl` to `package:spry/impl.dart`.
3. The `MiddlewareNext` type is changed to `Next`, **this will be removed in 0.2 release**.

## 0.1.2

1. request store in context
2. response store in context
3. ⚠️ SPRY_HTTP_REQUEST -> SPRY_HTTP_ORIGIN_REQUEST store origin store http request

## 0.1.1

- Add `redirect` method to `Response`.
- Add `close` method to `Response`.

## 0.1.0

Publish a beta version.

## 0.0.12

Fix the `HttpException` is not exported.

## 0.0.11

Exception interception to prevent accidental program interruption.

## 0.0.10

- Add `SpryException`

## 0.0.9

- Revert response headers not set.

## 0.0.8

- Fix response headers not set.

## 0.0.7

1. Add `context` to response.
2. Context store add `contains` method.
3. Context add map style getter and setter operations.
4. Remove `response.json()` method.

## 0.0.6

- Apply `context` to request.

## 0.0.5

- Remove `spry.constants` exported in `spry` library.

## 0.0.4

- Move `spryHttpRequest` to `spry.constants` library.
- Add moddleware extension.

## 0.0.3

- Public `HttpRequest` store key.
