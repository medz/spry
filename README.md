# Spry

Spry is an HTTP middleware framework for Dart to make web applications and APIs more enjoyable to write.

```dart
import 'package:spry/spry.dart';

main() {
  final Spry spry = Spry();

  handler(Context context) {
    context.response.send('Hello Spry!');
  }

  spry.listen(port: 3000, handler);
}
```

## Installation

Add the following to your `pubspec.yaml`:

    dependencies:
      spry: any

Or install it from the command line:

    $ pub get

> Spry requires Dart SDK `>=1.18.6` or higher.

## Documentation

See the [Spry documentation](https://spry.odroe.com) for more information.

## Philosophy

Spry is a framework for building web applications and APIs. It is designed to be minimal and flexible.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for more information.

## Ecosystem

| Package | Version | Description |
| ------- | ------- | ----------- |
| [spry](packages/spry) | [![pub package](https://img.shields.io/pub/v/spry.svg)](https://pub.dartlang.org/packages/spry) | Spry is an HTTP middleware framework for Dart to make web applications and APIs more enjoyable to write. |
| [spry_router](packages/spry_router/) | [![pub package](https://img.shields.io/pub/v/spry_router.svg)](https://pub.dartlang.org/packages/spry_router) | A request router for the Spry web framework that supports matching handlers from path expressions. |
| [spry_session](packages/spry_session/) | [![pub package](https://img.shields.io/pub/v/spry_session.svg)](https://pub.dartlang.org/packages/spry_session) | A session middleware for the Spry web framework that supports cookie-based and memory-based sessions. |

## License

Spry is licensed under the MIT License. See [LICENSE](LICENSE) for more information.
