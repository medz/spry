# Spry Static

`spry_static` is a Handle/Middleware for the Dart [Spry](https://spry.fun) framework.

[![pub package](https://img.shields.io/pub/v/spry_static.svg)](https://pub.dartlang.org/packages/spry_static)

## Installation

Add `spry_static` to your `pubspec.yaml`:

```yaml
dependencies:
  spry_static: any
```

Or install it from the command line:

```bash
dart pub add spry_static
```

## Example

```dart
import 'package:spry/spry.dart';
import 'package:spry_static/spry_static.dart';

void main() async {
  final Spry spry = Spry();
  final Static static = Static.directory(
    directory: 'static',
    defaultFiles: ['index.html'],
  );

  await spry.listen(static, port: 3000);
  print('Listening on port http://localhost:3000');
}
```
