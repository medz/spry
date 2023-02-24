# Spry Urlencoded

The `spry_urlencoded` package provides a middleware and extension for [Spry](https://spry.fun) to parse `application/x-www-form-urlencoded` request body.

[![Pub version](https://img.shields.io/pub/v/spry_urlencoded.svg)](https://pub.dev/packages/spry_urlencoded)

## Installation

Add `spry_urlencoded` to your `pubspec.yaml`:

```yaml
dependencies:
  spry_urlencoded: latest
```

Or install it from the command line:

```bash
dart pub add spry_urlencoded
```

## Usage

Read the `request.urlencoded` property to get the parsed body:

```dart
import 'package:spry_urlencoded/spry_urlencoded.dart';

void handler(Context context) async {
  print(await context.request.urlencoded());
}
```

## Configuration

The `Urlencoded` middleware can be configured with the following options:

- `encoding` - The encoding of the request body. Defaults to `utf8`.

```dart
import 'package:spry/spry.dart';
import 'package:spry_urlencoded/spry_urlencoded.dart';

void handler(Context context) async {
  final Map<String, String> urlencoded = await context.request.urlencoded();

  print(urlencoded);
}

final spry = Spry();
final urlencoded = Urlencoded(
  string: utf8,
  part: utf8,
);

spry.use(urlencoded);

await spry.listen(handler, port: 3000);
```

> **Note**: The `Urlencoded` middleware is optional. You can use the `request.urlencoded` extension method to parse the request body.
