import 'dart:async';

import 'package:meta/meta.dart';
import 'package:routingkit/routingkit.dart';

import 'http/request.dart';
import 'http/response.dart';

/// Request event interface.
///
/// This [Event] is also the context of the request.
abstract interface class Event {
  /// Contains custom data that was added to the request within [Handler].
  Map get locals;

  /// Gets current event request.
  Request get request;

  /// Gets/sets response.
  abstract Response response;

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
