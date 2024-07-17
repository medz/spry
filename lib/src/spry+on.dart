// ignore_for_file: file_names

import 'package:routingkit/routingkit.dart';

import 'types.dart';

extension SpryOn on Spry {
  void on<T>(String method, String path, Handler<T> handler) {
    addRoute(router, method, path, handler);
  }
}
