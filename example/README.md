# Spry Examples

## [Spry Application Example](app.dart)

```dart
import 'package:spry/app.dart';

const app = Spry(
  routes: {
    '/': {'GET': welcome},
    '/say/:name': {'GET': sayName},
  },
);

Object? welcome(event) => '🎉 Welcome to Spry!';

Object? sayName(event) => 'Your name is ${event.params['name']}';

```
