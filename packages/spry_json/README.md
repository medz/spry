## Spry JSON

Spry JSON middleware and request/response extension, used to convert request body to JSON object or set response body to JSON object.

## Usage

```dart
import 'package:spry/spry.dart';
import 'package:spry_json/spry_json.dart';

void main() async {
  final Spry spry = Spry();

  handler(Context context) {
    context.response.json({"foo": "bar"});
  }

  spry.listen(handler, port: 3000);
}

```

## Configuration

Use the `SpryJson` middleware to parse the request body as JSON.

```dart
final SpryJson json = SpryJson(
  // ... See below for configuration options.
);

spry.use(json);

// Or with a router.
router.use(json);
```

The `SpryJson` object is a Spry middleware, so it can be used with a `Spry` instance or a `Router` instance.

### Options

| Name | Type | Default | Description |
| ---- | ---- | ------- | ----------- |
| `reviver` | `Object? Function(Object? key, Object? value)` | `null` | A function that can be used to transform the results. See `JsonCodec` for more information. |
| `toEncodable` | `Object? Function(dynamic object)` | `null` | A function that can be used to encode non-JSON values. See `JsonCodec` for more information. |
| `validateRequestHeader` | `bool` | `false` | If `true`, the middleware will validate the `Content-Type` header of the request. If the header is not `application/json`, the middleware will throw a `SpryJsonValidateException`. |
| `contentType` | `ContentType` | `ContentType.json` | The `ContentType` to set on the response and validate for the request. |
| `encoding` | `Encoding` | `utf8` | The encoding to use when parsing the request body or encoding the response body (If the response encoding is not set). |
| `hijackParseError` | `bool` | `false` | If `true`, no error will be thrown when parsing the request content as json, but null will be returned. |