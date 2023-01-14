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
