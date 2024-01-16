// ignore_for_file: file_names

import 'dart:async';
import 'dart:io';

import '../application.dart';
import 'map+value_of.dart';

typedef ServerFactory = FutureOr<HttpServer> Function(Application application);

extension Application$Factory on Application {
  /// Returns spry application server factory.
  ServerFactory? get factory {
    if (locals[#spry.server.initialized] == true) return null;
    return locals.valueOf(#spry.server.factory, (_) => null);
  }
}
