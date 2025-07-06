import 'dart:async';

import 'package:oxy/oxy.dart';

class TtlOptions {
  TtlOptions({this.cert, this.key, this.passphrase});

  /// File path or inlined TLS certificate in PEM format
  final String? cert;

  /// File path or inlined TLS private key in PEM format
  final String? key;

  /// Passphrase for the private key
  final String? passphrase;
}

abstract interface class Platform {
  /// Returns the platform runtime listen at the given url
  String? get url;

  /// Returns a [Future] that resolves when the server is ready.
  FutureOr<void> ready();

  /// Start listening for incoming connections.
  void serve({
    required Future<Response> Function(Request request) fetch,
    String? hostname,
    int? port,
    required bool reusePort,
    TtlOptions? ttl,
  });

  /// Stop listening to prevent new connections from being accepted.
  ///
  /// By default, the server will wait for all ongoing operations to complete before shutting down.
  /// If [force] is set to `true`, the server will immediately shut down without waiting for ongoing operations.
  Future<void> close([bool force = false]);

  /// The `waitUntil` extends the lifetime of your platform,
  /// allowing you to perform work without blocking returning a response
  void waitUntil<E>(FutureOr<E> future);

  /// Returns the client IP address and port of the given Request.
  /// If the request was closed or is a unix socket, returns null.
  String? requestIP(Request request);
}
