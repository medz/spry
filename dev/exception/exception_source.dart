class ExceptionSource<T> {
  final T exception;
  final StackTrace stackTrace;

  final bool Function() _responseClosedFactory;

  const ExceptionSource({
    required this.exception,
    required this.stackTrace,
    required bool Function() responseClosedFactory,
  }) : _responseClosedFactory = responseClosedFactory;

  /// Returns `true` if the response is closed.
  bool get isResponseClosed => _responseClosedFactory();

  /// Creates a new [ExceptionSource] with the given [exception].
  ExceptionSource<R> cast<R>(R exception) {
    return ExceptionSource(
      exception: exception,
      stackTrace: stackTrace,
      responseClosedFactory: _responseClosedFactory,
    );
  }
}
