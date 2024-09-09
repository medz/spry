import 'dart:async';

import 'package:meta/meta.dart';
import 'package:routingkit/routingkit.dart';

import 'http/request.dart';

/// Request event interface.
///
/// This [Event] is also the context of the request.
abstract interface class Event {
  /// Gets a value of type [T].
  R? get<R>(Object? key);

  /// Sets a [value] to the [Event] for [key].
  void set<E>(Object? key, E value);

  /// Remove the value already set to the [Event].
  void remove(Object? key);

  /// Gets current event request.
  Request get request;

  /// Returns event raw.
  dynamic get raw;

  /// Returns Spry application
  Spry get app;
}

/// Spry handler.
typedef Handler<T> = FutureOr<T> Function(Event event);

/// Spry Routes
abstract interface class Routes {
  /// Adds a handler on match [method] and [path].
  void on<T>(String? method, String path, Handler<T> handler);
}

/// Spry application.
abstract interface class Spry implements Routes {
  /// The [RouterContext] bound to the current [Spry] application
  @internal
  RouterContext<Handler> get router;

  /// Stack handler in Spry application.
  @internal
  List<Handler> get stack;

  /// Adds a [Handler] into [stack].
  void use<T>(Handler<T> handler);
}

/// Spry error.
abstract interface class SpryError implements Error {
  /// The error message.
  String get message;
}
