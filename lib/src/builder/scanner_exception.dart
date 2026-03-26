/// Error thrown when route discovery or semantic validation finds invalid input.
final class RouteScanException implements Exception {
  /// Creates a route scan exception with a human-readable [message].
  const RouteScanException(this.message);

  /// Human-readable error description.
  final String message;

  @override
  String toString() => 'RouteScanException: $message';
}
