import 'dart:io';

import 'package:stack_trace/stack_trace.dart';

import '../utils/catch_top_level_errors.dart';

class Spry {
  /// Top-level error handler.
  ///
  /// This is called when an error is thrown in the request handler.
  void _error(Object error, StackTrace stackTrace) {
    final Chain chain = Chain.forTrace(stackTrace)
        .foldFrames((frame) => frame.isCore || frame.package == 'spry')
        .terse;

    stderr.writeln('ERROR - ${DateTime.now()}');
    stderr.writeln(error);
    stderr.writeln(chain);
  }

  /// Top-level request handler.
  ///
  /// This is called when a request is received.
  ///
  /// Example:
  /// ```dart
  /// final spry = Spry();
  /// final server = await HttpServer.bind('localhost', 8080);
  ///
  /// server.listen(spry);
  /// ```
  void call(HttpRequest request) {
    // TODO: Implement request handler.
    request.response.statusCode = HttpStatus.notImplemented;
    request.response.close();
  }

  /// [Spry] binds to the [HttpServer] and handles requests.
  ///
  /// Example:
  /// ```dart
  /// final spry = Spry();
  /// final server = await HttpServer.bind('localhost', 8080);
  ///
  /// spry.bind(server);
  /// ```
  HttpServer bind(HttpServer server) =>
      catchTopLevelErrors(() => server..listen(this), _error) ?? server;

  /// listen on a server.
  ///
  /// The function creates a new [HttpServer] and binds it to [Spry].
  ///
  /// Example:
  /// ```dart
  /// final spry = Spry();
  /// final server = spry.listen(port: 3000);
  /// ```
  Future<HttpServer> listen({
    int port = 0,
    InternetAddress? address,
    bool shared = false,
    bool v6Only = false,
    int backlog = 0,
    SecurityContext? context,
    bool requestClientCertificate = false,
  }) async {
    final factory = context == null ? HttpServer.bind : HttpServer.bindSecure;

    // Create HttpServer positional arguments.
    final positionalArguments = [
      address ?? InternetAddress.anyIPv4,
      port,
      if (context != null) context,
    ];

    // Create HttpServer named arguments.
    final namedArguments = {
      Symbol('shared'): shared,
      Symbol('v6Only'): v6Only,
      Symbol('backlog'): backlog,
      if (context != null)
        Symbol('requestClientCertificate'): requestClientCertificate,
    };

    // Create HttpServer.
    final HttpServer server =
        await Function.apply(factory, positionalArguments, namedArguments);

    // Bind HttpServer to Spry.
    return bind(server);
  }
}
