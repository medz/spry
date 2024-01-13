// ignore_for_file: file_names

import 'dart:async';
import 'dart:io';

import 'application+handler.dart';
import 'application.dart';

extension Application$Listen on Application {
  /// Simply listen to the [HttpServer] and handle incoming requests.
  StreamSubscription<HttpRequest> listen() => server.listen(handler);
}
