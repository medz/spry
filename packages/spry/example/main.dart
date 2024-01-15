import 'dart:io';

import 'package:spry/spry.dart';

void main(List<String> args) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 3000);
  final app = Application(server);

  app.get('/', (request) => 'Hello, Spry!');
  app.get('/hello/:name', (request) => 'Hello, ${request.params.get('name')}!');
  app.get('/hello/:name/:age', (request) {
    final name = request.params.get('name');
    final age = request.params.get('age');

    return 'Hello, $name! You are $age years old.';
  });
  app.get(
    '/hello',
    (request) => {
      '/': 'Hello, Spry!',
      '/hello': 'Index of hello.',
      '/hello/:name': 'Say hello to someone.',
      '/hello/:name/:age': 'Say hello to someone with age.',
    },
  );
  app.post('/hello', (request) async => 'Hello, ${await request.text()}!');

  app.listen();
  print('Listening on http://localhost:3000');
}
