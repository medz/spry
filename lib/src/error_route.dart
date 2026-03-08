import 'package:ht/ht.dart' show HttpMethod;

import 'handler.dart';

final class ErrorRoute {
  const ErrorRoute({required this.path, required this.handler, this.method});

  final String path;
  final HttpMethod? method;
  final ErrorHandler handler;
}
