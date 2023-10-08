import 'dart:io';

import '../3.0/spry.dart';

Response handler(RequestEvent event) {
  event.setHeaders({'Content-Type': 'text/plain2'});

  return Response('Hello, World!');
}

Future<void> main() async {
  final spry = Spry(handler);
  final HttpServer server = await HttpServer.bind('localhost', 3000);

  server.listen(spry);
  print('Listening on http://localhost:3000');
}
