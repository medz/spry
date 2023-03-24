import 'interceptor/rethrow_exception.dart';

/// Eager response.
///
/// If you want to throw [EagerResponse] in your [Middleware] or [Handler] to
/// end the request, you can use this class.
///
/// ```dart
/// handler: (context) {
///  throw EagerResponse();
/// }
/// ```
class EagerResponse implements RethrowException {
  /// Create an instance of [EagerResponse].
  const EagerResponse._(this.onlyCloseConnection);

  /// Throws an [EagerResponse] exception.
  factory EagerResponse({bool onlyCloseConnection = false}) =>
      throw EagerResponse._(onlyCloseConnection);

  /// Only close the socket.
  final bool onlyCloseConnection;
}
