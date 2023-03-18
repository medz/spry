import 'dart:async';
import 'dart:convert';
import 'dart:io' hide HttpException;

import 'context.dart';
import 'handler.dart';
import 'redirect.dart';
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
  Middleware middleware = const RedirectResponseFilter();

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

      // Create next function.
      final next = _createNext(context, handler);

      try {
        await next();
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
        if (httpResponse.connectionInfo != null) {
          await httpResponse.close();
        }
      }
    };
  }

  /// Create a [Next] function.
  Next _createNext(Context context, Handler handler) {
    final next = _createWriteResponseNext(context, () => handler(context));

    return () => middleware(context, next);
  }

  /// Create write response next function.
  Next _createWriteResponseNext(Context context, Next next) {
    return () async {
      await next();

      final httpResponse = context.response.httpResponse;
      final stream = context.response.read();

      if (stream != null) {
        await httpResponse.addStream(stream);
      }
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
