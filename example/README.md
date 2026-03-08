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
import 'package:spry/app.dart';
import 'package:spry/server.dart';

Future<void> main() async {
  final app = Spry(
    routes: {
      '/': {HttpMethod.get: (_) => '🎉 Welcome to Spry!'},
      '/say/:name': {
        HttpMethod.get: (event) => 'Your name is ${event.params['name']}',
      },
    },
  );

  final server = serve(port: 3000, fetch: (request, _) => app.fetch(request));
  await server.ready();

  print('🎉 Spry Server listen on ${server.url}');
}

```

## Other

- [Using Isolate](isolate.dart)
