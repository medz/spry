# Session extension for [Spry](https://spry.fun)

Spry extension for session management.

## Installation

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  spry_session: any
```

Or run the following command:

```bash
dart pub add spry_session
```

## Usage

```dart
import 'package:spry/spry.dart';
import 'package:spry_session/spry_session.dart';

main() async {
  final Spry spry = Spry();

  handler(Context context) {
    context.session['foo'] = 'bar';

    context.response.send('Stored foo in session, session id: ${context.session.id}');
  }

  await spry.listen(handler, port: 3000);
}
```

## License

MIT License