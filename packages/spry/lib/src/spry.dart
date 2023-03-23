import 'dart:async';
import 'dart:convert';
import 'dart:io' hide HttpException;

import 'context.dart';
import 'eager.dart';
import 'handler.dart';
import 'interceptor/interceptor.dart';
import 'redirect.dart';
import 'middleware.dart';
import 'response.dart';

/// Spry framework application.
///
/// Example:
/// ```dart
/// final app = Spry();
/// app.use(logger);
/// app.listen((context) {
///  return Response.ok('Hello, World!');
/// });
/// ```
class Spry {
  /// Creates a new [Spry] instance.
  Spry({
    this.encoding = utf8,
    this.poweredBy = Spry,
  });

  /// Http server response default powered by header.
  final Object poweredBy;

  /// The [Request]/[Response] text encoding.
  final Encoding encoding;

  /// Sets or returns a [Middleware] chain.
  Middleware middleware = Interceptor.plainText();

  /// Apply a [Middleware] to [Spry] middleware chain.
  void use(Middleware middleware) =>
      this.middleware = this.middleware.use(middleware);

  /// Create a [HttpServer] listen handler.
  Future<void> Function(HttpRequest request) call(Handler handler) {
    return (HttpRequest httpRequest) async {
      final context = Context.fromHttpRequest(httpRequest)..[Spry] = this;
      final httpResponse = httpRequest.response;

      // Write default headers.
      _writeDefaultHeaders(httpResponse);

      try {
        return await Future.sync(_createNext(context, handler))
            .then((_) => _writeResponse(context))
            .then((_) => httpResponse.close());
      } on RedirectResponse catch (e) {
        return httpResponse.redirect(e.location, status: e.status);
      } on EagerResponse {
        return _writeResponse(context).then((_) => httpResponse.close());
      }
    };
  }

  /// Write response.
  Future<void> _writeResponse(Context context) async {
    final response = context.response;
    final httpResponse = response.httpResponse;

    // Write statuc code.
    httpResponse.statusCode = response.statusCode;

    // Write the stream.
    final stream = response.read();
    if (stream != null) {
      await httpResponse.addStream(stream);
    }
  }

  /// Create a [Next] function.
  Next _createNext(Context context, Handler handler) {
    return () => middleware(context, () => handler(context));
  }

  /// Write default headers.
  void _writeDefaultHeaders(HttpResponse httpResponse) {
    httpResponse.headers
      ..set('x-powered-by', Spry)
      ..date = DateTime.now().toUtc();
  }

  /// Listen on the specified [address] and [port].
  Future<HttpServer> listen(
    Handler handler, {
    Object? address,
    int port = 0,
    bool shared = false,
    bool v6Only = false,
    int backlog = 0,
  }) async {
    final socket = await ServerSocket.bind(
      address ?? InternetAddress.anyIPv4,
      port,
      shared: shared,
      v6Only: v6Only,
      backlog: backlog,
    );

    return HttpServer.listenOn(socket)..forEach(call(handler));
  }
}
