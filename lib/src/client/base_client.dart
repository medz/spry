import 'dart:async';

import 'package:ht/ht.dart' show Headers;
import 'package:oxy/oxy.dart' show Oxy;

/// Minimal runtime base for generated Spry clients.
abstract class BaseSpryClient {
  /// Creates a client runtime shell.
  BaseSpryClient({required this.endpoint, this.headers});

  /// Base endpoint used by the client.
  final Uri endpoint;

  /// Optional static headers applied globally by the generated client.
  Headers? get globalHeaders => null;

  /// Shared oxy runtime used by generated route helpers.
  late final oxy = Oxy(.new(baseUrl: endpoint, defaultHeaders: globalHeaders));

  /// Optional runtime headers provider evaluated per request.
  final FutureOr<Headers> Function()? headers;
}
