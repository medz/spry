part of spry.contracts;

/// Spry handler contract.
abstract class Handler {
  /// Handles the given [request].
  Future<Response> handle(Request request);
}
