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

See the [Spry documentation](https://spry.fun) for more information.

## Philosophy

Spry is a framework for building web applications and APIs. It is designed to be minimal and flexible.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for more information.

## License

Spry is licensed under the MIT License. See [LICENSE](LICENSE) for more information.
