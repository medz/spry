part of spry.core;

/// Spry handler
abstract class Handler implements contracts.Handler {
  const factory Handler(
    Future<contracts.Response> Function(contracts.Request request) handler,
  ) = _FunctionHandler;
}

/// Function handler wrapper
class _FunctionHandler implements Handler {
  const _FunctionHandler(this.handler);

  /// Function handler.
  final Future<contracts.Response> Function(contracts.Request request) handler;

  @override
  Future<contracts.Response> handle(contracts.Request request) =>
      handler(request);
}
