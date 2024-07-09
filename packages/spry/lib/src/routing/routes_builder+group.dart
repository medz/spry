// ignore_for_file: file_names

import '../handler/closure_handler.dart';
import '../handler/handler.dart';
import '../utils/next.dart';
import 'routes_builder.dart';

extension RoutesBuilderGroup on RoutesBuilder {
  /// Creates and returns a new [RoutesBuilder] wrapped in the supplied array of
  /// [Middleware] and paths.
  ///
  /// ```dart
  /// final routes = app.groupd(route: '/admin', uses: [
  ///     ClosureHandler(cookie()), // Admin need cookie.
  /// ]);
  ///
  /// routes.get('/users', (event) => 'users');
  /// routes.get('/posts', (event) => 'posts');
  ///
  /// // GET /admin/users -> users
  /// // GET /admin/posts -> posts
  /// ```
  ///
  /// - [uses] - The [Handler]s to wrap the [RoutesBuilder] in.
  /// - [path] - The path to wrap the [RoutesBuilder] in.
  RoutesBuilder groupd({String? route, Iterable<Handler>? uses}) {
    RoutesBuilder current = this;

    if (route != null && route.isNotEmpty) {
      current = _RouteGroupRoutesBuilder(current, route);
    }

    if (uses != null && uses.isNotEmpty) {
      final handlers = switch (uses) {
        List<Handler>(reversed: final reversed) => reversed,
        Iterable<Handler>(toList: final toList) => toList().reversed,
      };

      current = _UsesGroupRoutesBuilder(current, handlers);
    }

    return current;
  }

  /// Creates and returns a new [RoutesBuilder] wrapped in the supplied array of
  /// [Handler] with closure containing routes.
  ///
  /// @see [groupd]
  T group<T>(
    T Function(RoutesBuilder routes) closure, {
    String? route,
    Iterable<Handler>? uses,
  }) {
    return closure(groupd(route: route, uses: uses));
  }
}

class _RouteGroupRoutesBuilder implements RoutesBuilder {
  const _RouteGroupRoutesBuilder(this.parent, this.prefix);

  final RoutesBuilder parent;
  final String prefix;

  @override
  void addRoute(String method, String route, Handler handler) {
    parent.addRoute(method, '$prefix/$route', handler);
  }
}

class _UsesGroupRoutesBuilder implements RoutesBuilder {
  const _UsesGroupRoutesBuilder(this.parent, this.handlers);

  final RoutesBuilder parent;
  final Iterable<Handler> handlers;

  @override
  void addRoute(String method, String route, Handler handler) {
    parent.addRoute(method, route, createHandlerWith(handler));
  }

  Handler createHandlerWith(Handler handler) {
    return handlers.fold(
      handler,
      (effect, current) => ClosureHandler((event) {
        event.locals.set(next, effect.handle);

        return current.handle(event);
      }),
    );
  }
}
