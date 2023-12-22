import 'package:spry/spry.dart';

void main(List<String> args) async {
  final app = Spry(arguments: args);

  app.on((event) => 'Hello, World!', method: 'get', path: '/');

  await app.startup();
}
