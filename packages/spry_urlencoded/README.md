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
