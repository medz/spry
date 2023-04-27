part of spry.core;

/// Spry Middleware.
abstract class Middleware implements contracts.Middleware {
  /// Creates a new middleware.
  const factory Middleware(
    Future<contracts.Response> Function(
      contracts.Request request,
      contracts.Handler handler,
    )
        middleware,
  ) = _FunctionMiddleware;
}

/// Function middleware wrapper.
class _FunctionMiddleware implements Middleware {
  /// Creates a new function middleware.
  const _FunctionMiddleware(this.middleware);

  /// Function middleware.
  final Future<contracts.Response> Function(
    contracts.Request request,
    contracts.Handler handler,
  ) middleware;

  @override
  Future<contracts.Response> process(
    contracts.Request request,
    contracts.Handler handler,
  ) =>
      middleware(request, handler);
}
