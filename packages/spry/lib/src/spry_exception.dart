/// Spry base exception.
///
/// This exception is thrown when an error occurs in the Spry framework.
class SpryException implements Exception, Error {
  /// The exception message.
  final Object? message;

  @override
  final StackTrace? stackTrace;

  /// Creates a new [SpryException].
  const SpryException(this.message, [this.stackTrace]);

  /// Creates a new [SpryException] from a [message].
  ///
  /// The [stackTrace] is automatically captured.
  factory SpryException.fromMessage(Object? message) =>
      SpryException(message, StackTrace.current);
}
