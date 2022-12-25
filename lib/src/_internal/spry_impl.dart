part of '../spry.dart';

/// [Spry] implementation.
class _SpryImpl implements Spry {
  Middleware? middleware;

  @override
  void use(Middleware middleware) {
    this.middleware = this.middleware?.use(middleware) ?? middleware;
  }

  @override
  void Function(HttpRequest request) call(Handler handler) {
    return (HttpRequest request) async {
      final Context context = ContextImpl.fromHttpRequest(request);
      final Middleware middleware = this.middleware ?? emptyMiddleware;

      // Create a middleware next function.
      FutureOr<void> next() async {
        await handler(context);

        // Close response if not already closed.
        await context.response.close();
      }

      /// Call middleware.
      await middleware(context, next);
    };
  }

  /// Default empty middleware.
  static FutureOr<void> emptyMiddleware(Context context, MiddlewareNext next) =>
      next();
}
