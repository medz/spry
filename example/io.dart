import 'dart:io';

import 'package:spry/spry.dart';
import 'package:spry/io.dart';

void main() async {
  final app = createSpry();

  app.on('get', '/', (event) => Response.json({"a": 1}));

  final handler = toIOHandler(app);
  final server = await HttpServer.bind('127.0.0.1', 3000);

  server.listen(handler);

  print('🎉 Server listen on http://127.0.0.1:3000');
}
