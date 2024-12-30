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
