import 'dart:io';

import 'request.dart';
import 'response.dart';
import 'spry.dart';

/// Spry framework context.
///
/// The context is a data store that is passed to all middleware and handlers.
///
/// ## Store
/// ```dart
/// // Store a value
/// context.set('foo', 'bar');
///
/// // Get a value
/// context.get('foo'); // 'bar'
/// ```
///
/// ## Request/Response
/// ```dart
/// // Get the request
/// context.request;
///
/// // Get the response
/// context.response;
/// ```
class Context {
  Context();

  /// Creates a new [Context] instance from [HttpRequest].
  factory Context.fromHttpRequest(HttpRequest httpRequest) {
    // Create a new context instance
    final Context context = Context()
      ..[HttpRequest] = httpRequest
      ..[HttpResponse] = httpRequest.response;

    return context
      ..[Context] = context
      ..[Request] = Request(context)
      ..[Response] = Response(context);
  }

  /// Data store container.
  ///
  /// **Note:** This is internal and should not be used.
  final _store = <dynamic, dynamic>{};

  /// The [Spry] [Request] instance of the current request.
  Request get request => this[Request];

  /// The [Spry] [Response] instance of the current request.
  Response get response => this[Response];

  /// Returns the [Spry] instance.
  Spry get app => this[Spry];

  /// Has a value in the context.
  bool contains(dynamic key) => _store.containsKey(key);

  /// Set a value to the context.
  operator []=(dynamic key, Object? value) => _store[key] = value;

  /// Get a value from the context.
  operator [](dynamic key) => _store[key];
}
