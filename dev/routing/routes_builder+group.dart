// ignore_for_file: file_names

import 'dart:async';
import 'dart:io';

import 'package:routingkit/routingkit.dart';

import '../handler/handler.dart';
import '../middleware/middleware.dart';
import 'route.dart';
import 'routes_builder.dart';

extension RoutesBuilder$Group on RoutesBuilder {
  /// Creates and returns a new [RoutesBuilder] wrapped in the supplied array of
  /// [Middleware] and paths.
  ///
  /// ```dart
  /// final routes = app.groupd(path: '/api', middleware: [authMiddleware]);
  ///
  /// routes.get('/users', (req) => 'users');
  /// routes.get('/posts', (req) => 'posts');
  ///
  /// // GET /api/users -> users
  /// // GET /api/posts -> posts
  /// ```
  ///
  /// - [middleware] - The middleware to wrap the [RoutesBuilder] in.
  /// - [path] - The path to wrap the [RoutesBuilder] in.
  RoutesBuilder groupd({Iterable<Middleware>? middleware, String? path}) {
    RoutesBuilder current = this;

    if (path != null && path.isNotEmpty) {
      current = _PathGroupedRoutesBuilder(current, path.asSegments);
    }

    if (middleware != null && middleware.isNotEmpty) {
      current = _MiddlewareGroupedRoutesBuilder(current, middleware);
    }

    return current;
  }

  /// Creates and returns a new [RoutesBuilder] wrapped in the supplied array of
  /// [Middleware] with closure containing routes.
  ///
  /// @see [groupd]
  RoutesBuilder group(
    void Function(RoutesBuilder) closure, {
    Iterable<Middleware>? middleware,
    String? path,
  }) {
    final routes = groupd(middleware: middleware, path: path);
    closure(routes);

    return routes;
  }
}

class _PathGroupedRoutesBuilder implements RoutesBuilder {
  final RoutesBuilder parent;
  final Iterable<Segment> segments;

  const _PathGroupedRoutesBuilder(this.parent, this.segments);

  @override
  void addRoute(Route route) {
    return parent.addRoute(route.copyWith(
      path: [...segments, ...route.segments],
    ));
  }
}

class _MiddlewareGroupedRoutesBuilder implements RoutesBuilder {
  final RoutesBuilder parent;
  final Iterable<Middleware> middleware;

  const _MiddlewareGroupedRoutesBuilder(this.parent, this.middleware);

  @override
  void addRoute(Route route) {
    return parent.addRoute(route.copyWith(
      handler: middleware.makeHandler(route.handler),
    ));
  }
}

class _MiddlewareHandler<T> implements Handler<T> {
  final Handler<T> handler;
  final Iterable<Middleware> middleware;

  const _MiddlewareHandler(this.handler, this.middleware);

  @override
  FutureOr<T> handle(HttpRequest request) async {
    final completer = Completer<T>.sync();

    Next next = () async => completer.complete(await handler.handle(request));
    for (final middleware in middleware.reversed) {
      next = () async => middleware.process(request, next);
    }

    return next().then((_) => completer.future);
  }
}

extension on Iterable<Middleware> {
  Handler<T> makeHandler<T>(Handler<T> handler) =>
      _MiddlewareHandler(handler, this);

  /// Reversed middleware
  Iterable<Middleware> get reversed => toList(growable: false).reversed;
}
