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
3. Only support objects and arrays as the root element of the json.

## 0.1.1

1. Update `spry` to `0.1.3`.
2. Fix docs typo.

## 0.1.0

- Throw `SpryException` when the request is not a json.
- If validate media type failed, the response will be `415 Unsupported Media Type`.

## 0.0.1

First release.
