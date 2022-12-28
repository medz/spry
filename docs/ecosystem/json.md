---
title: JSON
---

# Spry JSON

Spry JSON middleware and request/response extension, used to convert request body to JSON object or set response body to JSON object.

[![pub package](https://img.shields.io/pub/v/spry_json.svg)](https://pub.dartlang.org/packages/spry_json)

## Install

Add dependencies in `pubspec.yaml`:

```yaml
dependencies:
  spry_json: any
```

Or install via command line:

```bash
$ dart pub add spry_json
```

## Usage

The Spry JSON extension is zero-configuration and only needs to be imported to use:

```dart
import 'package:spry/spry.dart';
import 'package:spry_json/spry_json.dart';

handler(Context context) {
   context.response.json({"foo": "bar"});
}
```

### Request JSON body

When you need it, you can get the requested JSON object via `context.request.json()`:

```dart
handler(Context context) {
   final json = context.request.json();
  
   //...
}
```

### Response JSON body

To return a JSON object, you can use the `context.response.json()` method:

```dart
handler(Context context) {
   context.response.json({"foo": "bar"});
}
```

It will automatically set the `Content-Type` to `application/json`.

## Configuration

Spry JSON is zero configuration, but you can create a JSON configuration middleware through `SpryJson` object:

```dart
import 'package:spry_json/spry_json.dart';

final SpryJson json = SpryJson(
   /// options
);

spry. use(json);
```

### Options

| Name | Type | Default | Description |
| ---- | ---- | ------- | ----------- |
| `reviver` | `Object? Function(Object? key, Object? value)` | `null` | A function that can be used to transform the results. See `JsonCodec` for more information. |
| `toEncodable` | `Object? Function(dynamic object)` | `null` | A function that can be used to encode non-JSON values. See `JsonCodec` for more information. |
| `validateRequestHeader` | `bool` | `false` | If `true`, the middleware will validate the `Content-Type` header of the request. If the header is not `application/json`, the middleware will throw a `SpryJsonValidateException`. |
| `contentType` | `ContentType` | `ContentType.json` | The `ContentType` to set on the response and validate for the request. |
| `encoding` | `Encoding` | `utf8` | The encoding to use when parsing the request body or encoding the response body (If the response encoding is not set). |
| `hijackParseError` | `bool` | `false` | If `true`, no error will be thrown when parsing the request content as json, but null will be returned. |