import 'dart:async';

import 'package:prexp/prexp.dart';
import 'package:spry/spry.dart';
import 'package:spry/extension.dart';

import '../param_middleware.dart';
import '../route.dart';
import 'constants.dart';
import 'empty_functions.dart';

class RouteImpl extends Route {
  @override
  final String fullPath;

  @override
  final String path;

  @override
  final String verb;

  /// The roite handler.
  final Handler handler;

  /// The route middleware.
  Middleware? middleware;

  /// The route path matcher.
  final PathMatcher matcher;

  final Map<String, ParamMiddleware> paramMiddleware = {};

  /// constructor.
  RouteImpl._internal({
    required this.verb,
    required this.path,
    required this.handler,
    required this.matcher,
    required this.fullPath,
  });

  /// Create a new route.
  factory RouteImpl({
    required String verb,
    required String path,
    required Handler handler,
    required String fullPath,
  }) {
    final Prexp prexp = Prexp.fromString(fullPath);
    final PathMatcher matcher = PathMatcher.fromPrexp(prexp);

    return RouteImpl._internal(
      verb: verb,
      path: path,
      handler: handler,
      matcher: matcher,
      fullPath: fullPath,
    );
  }

  @override
  void use(Middleware middleware) {
    this.middleware = this.middleware?.use(middleware) ?? middleware;
  }

  @override
  FutureOr<void> call(Context context) async {
    final Map<String, Object?> params =
        context.get(SPRY_REQUEST_PARAMS) as Map<String, Object?>? ?? {};
    for (final String name in params.keys) {
      final ParamMiddleware? middleware = paramMiddleware[name];
      if (middleware != null) {
        next(Object? value) => params[name] = value;

        // Call middleware
        await middleware(context, params[name], next);
      }
    }

    /// The route middleware.
    final Middleware middleware = this.middleware ?? emptyMiddleware;

    // Call middleware create a handler.
    return middleware(context, () => handler(context));
  }

  @override
  PrexpMatch? match(String path) {
    final Iterable<PrexpMatch> matches = matcher(path);

    return matches.isNotEmpty ? matches.first : null;
  }

  @override
  void param(String name, ParamMiddleware middleware) {
    paramMiddleware[name] =
        paramMiddleware[name]?.use(middleware) ?? middleware;
  }

  @override
  String toString() => '$verb $fullPath';
}
