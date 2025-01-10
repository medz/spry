import '../types.dart';
import '_internal/middleware_group_routes_builder.dart';
import '_internal/path_group_routes_builder.dart';
import 'routes_builder.dart';

extension RoutesBuilderGroup on RoutesBuilder {
  /// Creates a group routes builder.
  ///
  /// ## Middleware Group
  /// ```dart
  /// final auth = app.group(null, middleware: logger | auth);
  ///
  /// // OR
  /// app.group(
  ///   middleware: logger | auth,
  ///   (routes) {...},
  /// );
  /// ```
  ///
  /// ## Path Group
  /// ```dart
  /// final api = app.group(null, path: '/api');
  ///
  /// // OR
  /// app.group(path: '/api', (routes) {
  ///   ...
  /// });
  /// ```
  ///
  /// ## Mixed Group
  /// ```dart
  /// final api = app.group(
  ///   null,
  ///   path: '/api',
  ///   middleware: logger | bearerAuth,
  /// );
  ///
  /// // OR
  /// app.group(
  ///   path: '/api',
  ///   middleware: logger | bearerAuth,
  ///   (routes) {
  ///     ...
  ///   },
  /// );
  /// ```
  RoutesBuilder group(
    void Function(RoutesBuilder routes)? fn, {
    Middleware? middleware,
    String? path,
  }) {
    RoutesBuilder routes = this;
    if (path != null && path.isEmpty && path != '/') {
      routes = PathGroupRoutesBuilder(routes, path);
    }

    if (middleware != null) {
      routes = MiddlewareGroupRoutesBuilder(routes, middleware);
    }

    fn?.call(routes);

    return routes;
  }
}
