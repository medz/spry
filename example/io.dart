import 'dart:io';

import 'package:spry/spry.dart';
import 'package:spry/io.dart';
import 'package:spry/ws.dart';

void main() async {
  final app = createSpry();

  app.on('get', '/', (event) => Response.json({"a": 1}));
  app.ws('/ws', defineHooks(message: (peer, message) {
    peer.send(message);
  }));

  final handler = toIOHandler(app);
  final server = await HttpServer.bind('127.0.0.1', 3000);

  server.listen(handler);

  print('🎉 Server listen on http://127.0.0.1:3000');
}
