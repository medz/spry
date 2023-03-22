library spry.router.operator;

import 'package:spry/spry.dart';
import 'package:spry_router/spry_router.dart';

/// The [Spry framework](https://spry.fun) [Router] operator.
///
/// Use operators to chain call routing functions.
extension RouterOperator on Router {
  /// Merge the given [Router] into this [Router].
  ///
  /// Returns the left-hand side [Router].
  ///
  /// **Note:** This is a convenience method for [Router.merge].
  /// ```dart
  /// final router = Router();
  ///
  /// router & Router();
  /// ```
  Router operator &(Router router) => this..merge(router);

  /// Register a [Middleware] to the router.
  ///
  /// Returns the left-hand side [Router].
  ///
  /// **Note:** This is a convenience method for [Router.use].
  /// ```dart
  /// final router = Router();
  ///
  /// router | Middleware();
  /// ```
  Router operator |(Middleware middleware) => this..use(middleware);
}
