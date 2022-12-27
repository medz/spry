# Spry router

Spry makes it easy to build web applications and API applications in Dart with middleware composition processors. This package provides Spry with request routing handlers that dispatch requests to handlers by routing matching patterns.

## Installation

Add the following to your `pubspec.yaml` file:

    dependencies:
      spry_router: any

Or install it from the command line:

    $ pub install

## Example

```dart
import 'dart:io';
import 'package:spry/spry.dart';
import 'package:spry_router/spry_router.dart';

void main() async {
  final Spry spry = Spry();
  final Router router = Router();

  router.all('/', (context) {
    context.response
      ..status(HttpStatus.ok)
      ..send('Hello World!');
  });

  router.get('/hello/:name', (Context context) {
    final String name = context.request.param('name') as String;

    context.response
      ..status(HttpStatus.ok)
      ..send('Hello $name!');
  });

  await spry.listen(router, port: 3000);

  print('Listening on http://localhost:3000');
}
```
