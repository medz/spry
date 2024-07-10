import 'dart:io';

import 'package:spry/spry.dart';
import 'package:spry/io.dart';

void main() async {
  // Create an Spry app instance.
  final app = Spry();

  // Add a new route that matches GET requests to / path
  app.get('/', (event) => "⚡️ Tadaa!");

  // Creates a HttpServer listen on data handler.
  final handler = const IOPlatform().createHandler(app);

  // Create an HttpServer.
  final server = await HttpServer.bind('127.0.0.1', 3000);

  // Listen requests of handler.
  server.listen(handler);

  print('🚀 HTTP server listen on http://127.0.0.1:3000');
}
