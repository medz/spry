import 'dart:async';

import 'package:routingkit/routingkit.dart';

import 'response.dart';

abstract interface class Event {
  T? get<T>(Object? key);
  void set<T>(Object? key, T value);
  void remove(Object? key);
}

typedef Handler<T> = FutureOr<T> Function(Event event);

abstract interface class Spry {
  RouterContext<Handler> get router;
  List<Handler> get stack;
}

abstract interface class SpryError implements Error {
  Response? get response;
  String get message;
}
