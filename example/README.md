# Spry Examples

## [Server Example](server.dart)

```dart
import 'package:spry/server.dart';

Future<void> main() async {
  final server = serve(
    hostname: 'localhost',
    port: 3000,
    fetch: (request, _) {
      return Response.fromString("Hey, I'm Spry cross server!");
    },
  );
  await server.ready();
  print('🎉 Server listen on ${server.url}');
}

```

## [Spry Application Example](app.dart)

```dart
import 'package:spry/spry.dart';

Future<void> main() async {
  final app = createSpry();

  app.all('/', (_) => '🎉 Welcome to Spry!');
  app.get('/say/:name', (event) {
    return 'Your name is ${event.params['name']}';
  });

  final server = app.serve(port: 3000);
  await server.ready();

  print('🎉 Spry Server listen on ${server.url}');
}

```
