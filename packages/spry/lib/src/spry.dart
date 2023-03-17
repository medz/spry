import 'dart:async';
import 'dart:convert';
import 'dart:io' hide HttpException;

import 'context.dart';
import 'handler.dart';
import 'spry_http_exception.dart';
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
  Middleware? middleware;

  /// Apply a [Middleware] to [Spry] middleware chain.
  void use(Middleware middleware) =>
      this.middleware = this.middleware?.use(middleware) ?? middleware;

  /// Create a [HttpServer] listen handler.
  Future<void> Function(HttpRequest request) call(Handler handler) {
    return (HttpRequest httpRequest) async {
      final context = Context.fromHttpRequest(httpRequest)..[Spry] = this;
      final httpResponse = httpRequest.response;

      // Write default headers.
      _writeDefaultHeaders(httpResponse);

      // Create next function.
      final next = _createNext(context, handler);

      try {
        await next();

        final body = context.response.read();
        if (body != null) {
          await httpResponse.addStream(body);
        }
      } on EagerResponse {
        final body = context.response.read();
        if (body != null) {
          await httpResponse.addStream(body);
        }
      } on SpryHttpException catch (e) {
        _writeHttpException(httpResponse, e);
      } catch (e, stackTrace) {
        final exception =
            SpryHttpException.internalServerError(stackTrace: stackTrace);
        _writeHttpException(httpResponse, exception);
      } finally {
        await httpResponse.close();
      }
    };
  }

  /// Create a [Next] function.
  Next _createNext(Context context, Handler handler) {
    return () async {
      if (middleware != null) {
        return middleware!(context, () => handler(context));
      }

      return handler(context);
    };
  }

  /// Write default headers.
  void _writeDefaultHeaders(HttpResponse httpResponse) {
    httpResponse.headers
      ..set('x-powered-by', Spry)
      ..date = DateTime.now().toUtc();
  }

  /// Write [SpryHttpException] to [HttpResponse].
  void _writeHttpException(HttpResponse httpResponse, SpryHttpException e) {
    httpResponse.statusCode = e.statusCode;
    httpResponse.headers.contentType = ContentType.text;
    httpResponse.contentLength = e.message.length;
    httpResponse.write(e.message);
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
