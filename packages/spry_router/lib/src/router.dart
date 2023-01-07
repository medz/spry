import 'dart:async';

import 'package:http_methods/http_methods.dart';
import 'package:prexp/prexp.dart';
import 'package:spry/spry.dart';
import 'package:spry/extension.dart';

import '_internal/constants.dart';
import 'param_middleware.dart';
import 'request_params_extension.dart';

part '_internal/router_impl.dart';

/// Spry [Router] interface.
abstract class Router {
  /// Create a new [Router] instance.
  factory Router() = _RouterImpl;

  /// Define a route for the given HTTP verb and path segment.
  void route(String verb, String path, Handler handler);

  /// Has a route been defined for the given HTTP verb and path segment?
  bool contains(String verb, String path);

  /// Merge the given [Router] into this [Router].
  void merge(Router router);

  /// Mount a [Handler] or [Router] to the given [prefix].
  void mount(String prefix, {Router? router, Handler? handler});

  /// Add a [Middleware] to the router.
  void use(Middleware middleware);

  /// Adds a [ParamMiddleware] to route parameters.
  void param(String name, ParamMiddleware middleware);

  /// Cast the router to a spry [Handler].
  FutureOr<void> call(Context context);

  /// Handle a HTTP verb request to a path.
  FutureOr<void> handle(String verb, String path, Context context);
}
