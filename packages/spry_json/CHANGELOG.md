# Changelog

## [1.0.0](https://github.com/odroe/spry/compare/spry_json-v0.4.0...spry_json-v1.0.0) (2023-03-14)


### ⚠ BREAKING CHANGES

* Fix wrong version dependencies

### Bug Fixes

* Fix wrong version dependencies ([f065f11](https://github.com/odroe/spry/commit/f065f11e72206e88353f7c93d2a06d3c559281ee))

## [0.4.0](https://github.com/odroe/spry/compare/spry_json-v0.3.0...spry_json-v0.4.0) (2023-03-14)


### Features

* MiddlewareNext -&gt; Next ([80b3da7](https://github.com/odroe/spry/commit/80b3da7927ad855032c8f3af2d965db5b2217c5f))

## 0.3.0

1. **SpryJson**: Remove `encoding` option.
2. **SpryJson**: Remove `contentType` option.
3. Adapt to `spry` 0.4.0.

## 0.2.1

Update readme.

## 0.2.0

### Breaking changes

1. Remove `SPRY_REQUEST_JSON_BODY` context key.
2. **SpryJson**: Remove `validateRequestHeader` option.
3. **SpryJson**: Remove `hijackParseError` option.
4. Only support objects and arrays as the root element of the json.

## 0.1.1

1. Update `spry` to `0.1.3`.
2. Fix docs typo.

## 0.1.0

- Throw `SpryException` when the request is not a json.
- If validate media type failed, the response will be `415 Unsupported Media Type`.

## 0.0.1

First release.
