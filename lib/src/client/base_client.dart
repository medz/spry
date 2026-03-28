import 'dart:async';

import 'package:ht/ht.dart' show Headers;

/// Minimal runtime base for generated Spry clients.
base class BaseSpryClient {
  /// Creates a client runtime shell.
  const BaseSpryClient({required this.endpoint, this.headers});

  /// Base endpoint used by the client.
  final Uri endpoint;

  /// Optional runtime headers provider evaluated per request.
  final FutureOr<Headers> Function()? headers;
}
