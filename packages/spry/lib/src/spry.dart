import 'dart:async';
import 'dart:io' hide HttpException;

import '_internal/context_impl.dart';
import 'extensions/middleware_extension.dart';
import 'context.dart';
import 'handler.dart';
import 'http_exception.dart';
import 'middleware.dart';
import 'response.dart';
import 'spry_exception.dart';

part '_internal/spry_impl.dart';

abstract class Spry {
  /// Creates a new [Spry] instance.
  factory Spry() => _SpryImpl();

  /// Use this to add a [Middleware] to [Spry].
  ///
  /// Example:
  /// ```dart
  /// final spry = Spry();
  /// spry.use(logger);
  /// ```
  void use(Middleware middleware);

  /// Create a [HttpServer] listen handler.
  void Function(HttpRequest) call(Handler handler);

  /// Create a [HttpServer] listen handler.
  Future<HttpServer> listen(
    Handler handler, {
    Object? address,
    required int port,
    int backlog = 0,
    bool shared = false,
    bool v6Only = false,
    SecurityContext? securityContext,
    bool requestClientCertificate = false,
  });
}
