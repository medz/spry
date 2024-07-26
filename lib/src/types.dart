import 'dart:async';

import 'package:meta/meta.dart';
import 'package:routingkit/routingkit.dart';

/// Request event interface.
///
/// This [Event] is also the context of the request.
abstract interface class Event {
  /// Gets a value of type [T].
  T? get<T>(Object? key);

  /// Sets a [value] to the [Event] for [key].
  void set<T>(Object? key, T value);

  /// Remove the value already set to the [Event].
  void remove(Object? key);
}

/// Spry handler.
typedef Handler<T> = FutureOr<T> Function(Event event);

/// Spry Routes
abstract interface class Routes {
  /// The [RouterContext] bound to the current [Spry] application
  @internal
  Router<Handler> get router;

  /// Adds a handler on match [method] and [path].
  void on<T>(String method, String path, Handler<T> handler);
}

/// Spry application.
abstract interface class Spry implements Routes {
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
