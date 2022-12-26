import 'dart:async';

import 'package:prexp/prexp.dart';
import 'package:spry/spry.dart';

abstract class Route {
  /// The route HTTP verb.
  String get verb;

  /// The route path.
  String get path;

  /// The route path expression.
  Prexp get prexp;

  /// The route wrapped handler middleware.
  void use(Middleware middleware);

  /// Call the route handler.
  FutureOr<void> call(Context context);
}
