import 'package:spry/spry.dart';

void main(List<String> args) async {
  final app = Application(arguments: args);

  app.on((event) => 'Hello, World!', method: 'get', path: '/');
  app.on((event) => 'Hello, ${event.parameters.get('name')}!',
      method: 'post', path: '/:name');

  await app.startup();
}
