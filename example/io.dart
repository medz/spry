import 'dart:io';

import 'package:spry/spry.dart';
import 'package:spry/io.dart';
import 'package:spry/ws.dart';

void main() async {
  final app = createSpry();

  app.all('/**', (event) => Response.text(getClientAddress(event) ?? ''));
  app.ws('/ws', defineHooks(message: (peer, message) {
    peer.send(message);
  }));

  final handler = toIOHandler(app);
  final server = await HttpServer.bind('127.0.0.1', 3000);

  server.listen(handler);

  print('🎉 Server listen on http://127.0.0.1:3000');
}
