import 'dart:async';

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

/// Spry application.
abstract interface class Spry {
  /// The [RouterContext] bound to the current [Spry] application
  RouterContext<Handler> get router;

  /// Stack handler in Spry application.
  List<Handler> get stack;
}

/// Spry error.
abstract interface class SpryError implements Error {
  /// The error message.
  String get message;
}
