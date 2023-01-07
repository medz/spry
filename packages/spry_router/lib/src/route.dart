import 'dart:async';

import 'package:prexp/prexp.dart';
import 'package:spry/spry.dart';

import 'param_middleware.dart';

abstract class Route {
  /// The route HTTP verb.
  String get verb;

  /// The route path.
  String get path;

  /// The route full path.
  String get fullPath;

  /// The route path matcher.
  PrexpMatch? match(String path);

  /// The route wrapped handler middleware.
  void use(Middleware middleware);

  /// Add a middleware to the route param.
  void param(String name, ParamMiddleware middleware);

  /// Call the route handler.
  FutureOr<void> call(Context context);
}
