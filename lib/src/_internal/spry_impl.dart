part of '../spry.dart';

const String _xPoweredBy = 'x-powered-by';

/// [Spry] implementation.
class _SpryImpl implements Spry {
  Middleware? middleware;

  @override
  void use(Middleware middleware) {
    this.middleware = this.middleware?.use(middleware) ?? middleware;
  }

  @override
  void Function(HttpRequest) call(Handler handler) {
    return (HttpRequest request) async {
      final Context context = ContextImpl.fromHttpRequest(request);
      final Middleware middleware = this.middleware ?? emptyMiddleware;

      // Create a middleware next function.
      FutureOr<void> next() => handler(context);

      /// Call middleware.
      await middleware(context, next);

      // Write and close response.
      return writeResponse(context, request.response);
    };
  }

  /// Write response.
  Future<void> writeResponse(Context context, HttpResponse response) async {
    final Response spryResponse = context.response;

    // Write status code.
    response.statusCode = spryResponse.statusCode;

    // Wirte x-powered-by.
    if (spryResponse.headers.value(_xPoweredBy) == null) {
      response.headers.set(_xPoweredBy, 'Spry');
    }

    // If no date header is set, set it to now.
    if (spryResponse.headers.date == null) {
      response.headers.date = DateTime.now().toUtc();
    }

    // Write cookies.
    for (final Cookie cookie in spryResponse.cookies) {
      response.headers.add(HttpHeaders.setCookieHeader, cookie.toString());
    }

    // Write body.
    if (spryResponse.isBodyReady) {
      await response.addStream(spryResponse.read());
    }

    // Close response.
    await response.close();
  }

  /// Default empty middleware.
  static FutureOr<void> emptyMiddleware(Context context, MiddlewareNext next) =>
      next();
}
