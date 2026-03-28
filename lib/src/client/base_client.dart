import 'dart:async';

import 'package:ht/ht.dart' show Headers;

/// Minimal runtime base for generated Spry clients.
abstract class BaseSpryClient {
  /// Creates a client runtime shell.
  const BaseSpryClient({required this.endpoint, this.headers});

  /// Base endpoint used by the client.
  final Uri endpoint;

  /// Optional static headers applied globally by the generated client.
  Headers? get globalHeaders => null;

  /// Optional runtime headers provider evaluated per request.
  final FutureOr<Headers> Function()? headers;
}
