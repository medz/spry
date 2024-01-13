import 'dart:io';

import 'dev/application+listen.dart';
import 'dev/application.dart';

void main(List<String> args) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 3000);
  final app = Application(server);

  app.listen();
  print('Listening on http://localhost:3000/');
}
