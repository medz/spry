import 'dart:io';

import 'package:spry/io.dart';

import 'app.dart';

void main() async {
  final handler = toIOHandler(app);
  final server = await HttpServer.bind('127.0.0.1', 3000);

  server.listen(handler);

  print('🎉 Server listen on http://127.0.0.1:3000');
}
