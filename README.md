Spry is a lightning-fast web framework for Dart.

```dart
import 'package:spry/spry.dart';

main() {
  final app = Spry();

  app.get('/', (req, res) {
    res.send('Hello, world!');
  });

  app.listen(3000);
}
```