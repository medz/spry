part of spry.contracts;

/// Spry middleware.
abstract class Middleware {
  /// Handles the given [request].
  Future<Response> process(Request request, Handler handler);
}
