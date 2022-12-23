Spry is a lightning-fast web framework for Dart.

```dart
import 'package:spry/spry.dart';

main() async {
  final spry = Spry();

  spry.get('/', (req, res) {
    res.send('Hello, world!');
  });

  await spry.listen(port: 3000);
}
```