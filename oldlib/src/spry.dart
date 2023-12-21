import 'dart:async';
import 'dart:convert';
import 'dart:io' hide HttpException;

import 'context.dart';
import 'handler.dart';
import 'interceptor/interceptor.dart';
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
  final Object? poweredBy;

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

      // Write default headers.
      _writeDefaultHeaders(httpRequest.response);

      try {
        await Future.sync(_createNext(context, handler));

        // Write response.
        return _writeResponse(context).then((response) => response.close());
      } on RedirectResponse catch (e) {
        return _writeResponse(context).then(
          (response) => response.redirect(e.location, status: e.status),
        );
      } on EagerResponse {
        return _writeResponse(context).then((response) => response.close());
      }
    };
  }

  /// Write response.
  Future<HttpResponse> _writeResponse(Context context) async {
    final response = context.response;
    final HttpResponse httpResponse = context[HttpResponse];

    try {
      // Write statuc code.
      httpResponse.statusCode = response.statusCode;
    } catch (e) {
      return httpResponse;
    }

    // Write content type.
    if (response.contentType != null) {
      httpResponse.headers.contentType = response.contentType;
    }

    // Write cookies.
    for (final cookie in response.cookies) {
      httpResponse.cookies.add(cookie);
    }

    // Write the stream.
    final stream = response.read();
    if (stream != null) {
      await httpResponse.addStream(stream);
    }

    return httpResponse;
  }

  /// Create a [Next] function.
  Next _createNext(Context context, Handler handler) {
    return () => middleware(context, () => handler(context));
  }

  /// Write default headers.
  void _writeDefaultHeaders(HttpResponse httpResponse) {
    if (poweredBy != null) {
      httpResponse.headers.set('x-powered-by', poweredBy!);
    }

    httpResponse.headers.date = DateTime.now().toUtc();
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
