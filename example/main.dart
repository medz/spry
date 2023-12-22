import 'package:spry/spry.dart';

void main(List<String> args) async {
  final app = Spry(arguments: args);

  app.on((event) => 'xxx', method: 'get', path: '/');
  await app.servers.current.start();

  print('Listening on http://${app.servers.hostname}:${app.servers.port}');
}
