part of '../router.dart';

/// Implement the [Router] interface.
class _RouterImpl implements Router {
  Middleware? middleware;
  final Map<String, ParamMiddleware> params = {};
  final List<Router> merged = [];
  final List<_Mount> mounted = [];
  final List<_Route> routes = [];

  @override
  FutureOr<void> call(Context context) =>
      handle(context.request.method, context.request.uri.path, context);

  @override
  bool contains(String verb, String path) => find(verb, path) != null;

  @override
  FutureOr<void> handle(String verb, String path, Context context) {
    // Normalize the verb and path.
    verb = verb.toLowerCase().trim();
    path = _normalizePath(path);

    // Find a handler for the given verb and path.
    final Handler? handler = find(verb, path);
    if (handler == null) {
      throw HttpException.notFound();
    }

    // Call the handler.
    return handler(context);
  }

  /// Find a handler for the given HTTP verb and path segment.
  Handler? find(String verb, String path) {
    // Find a route for the given verb and path.
    final _Route? route = findRoute(verb, path);
    if (route != null) return createHandlerFromRoute(path, route);

    // Find a handler for the merged routers.
    final Router? router = findMerged(verb, path);
    if (router != null) return createHandlerFromRouter(verb, path, router);

    // Find a handler for the mounted routers.
    final _Mount? mount = findMount(path);
    if (mount != null) return createHandlerFromMount(verb, path, mount);

    // No handler found.
    return null;
  }

  /// Create a handler from the given mount.
  Handler createHandlerFromMount(String verb, String path, _Mount mount) {
    // If the mount is a handler, call the handler.
    if (mount is _MountHandler) {
      return createHandlerFromHandler(mount.handler);
    }

    final _MountRouter mountRouter = mount as _MountRouter;
    final String subPath = mountRouter.suffix(path);

    return createHandlerFromRouter(verb, subPath, mountRouter.router);
  }

  /// Create a handler from the given handler.
  Handler createHandlerFromHandler(Handler handler) {
    return (Context context) async {
      // Create router middleware next function.
      void next() => handler(context);

      // Run the router param middlewares.
      await runParamMiddlewares(context);

      // Get the router middleware.
      //
      // If the router middleware is not found, call the route handler.
      if (middleware == null) return next();

      // Run the router middleware.
      return middleware!(context, next);
    };
  }

  /// Creare a handler from the given router.
  Handler createHandlerFromRouter(String verb, String path, Router router) {
    return (Context context) => router.handle(verb, path, context);
  }

  /// Create a handler from route.
  Handler createHandlerFromRoute(String path, _Route route) {
    // Path match result.
    final PrexpMatch match = route.match(path)!;

    return (Context context) async {
      // Create router middleware next function.
      void next() => route.handler(context);

      // Add the route params to the context.
      writeRouteParamsToContext(context, match.params);

      // Run the router param middlewares.
      await runParamMiddlewares(context);

      // Get the router middleware.
      //
      // If the router middleware is not found, call the route handler.
      if (middleware == null) return next();

      // Run the router middleware.
      return middleware!(context, next);
    };
  }

  // Run the router param middlewares.
  Future<void> runParamMiddlewares(Context context) async {
    final Map<String, Object?> requestParams = context.request.params;

    for (final MapEntry<String, Object?> entry in requestParams.entries) {
      final ParamMiddleware? middleware = params[entry.key];
      // If the param middleware is not found, skip.
      if (middleware == null) continue;

      // Create param middleware next function.
      void next(Object? value) =>
          writeRouteParamsToContext(context, {entry.key: value});

      // Run the param middleware.
      await middleware(context, entry.value, next);
    }
  }

  /// Write the route params to the context.
  void writeRouteParamsToContext(Context context, Map<String, Object?> params) {
    // Get the request params.
    final Map<String, Object?> requestParams = context.request.params;

    // Add the route params to the request params.
    requestParams.addAll(params);

    // Write the request params to the context.
    context.set(SPRY_REQUEST_PARAMS, requestParams);
  }

  /// Find a handler for the mounted routers.
  _Mount? findMount(String path) {
    return mounted
        .firstWhereOrNull((mount) => mount.segment.match(path) != null);
  }

  /// Find a handler for the merged routers.
  Router? findMerged(String verb, String path) {
    return merged.firstWhereOrNull((router) => router.contains(verb, path));
  }

  /// Find a handler for the defined routes with the given HTTP verb and path
  _Route? findRoute(String verb, String path) {
    // Without `all` verb, find a route for the given verb and path.
    _Route? route = routes
        .where((route) => route.verb == verb)
        .firstWhereOrNull((route) => route.match(path) != null);

    // With `all` verb, find a route for the given path.
    route ??= routes
        .where((route) => route.verb == 'all')
        .firstWhereOrNull((route) => route.match(path) != null);

    // Return the route.
    return route;
  }

  @override
  void merge(Router router) {
    if (merged.contains(router)) return;

    // Router add current middleware to the merged router.
    router.use(mergedMiddlewareBinder);

    // Add the router to the merged routers.
    merged.add(router);
  }

  /// Merged middleware binder.
  Future<void> mergedMiddlewareBinder(Context context, Next next) async {
    // Run the router param middlewares.
    await runParamMiddlewares(context);

    // If middleware is not found, call the next middleware.
    if (middleware == null) return next();

    // Run the router middleware.
    return middleware!(context, next);
  }

  @override
  void param(String name, ParamMiddleware middleware) {
    params[name] = params[name]?.use(middleware) ?? middleware;
  }

  @override
  void route(String verb, String path, Handler handler) {
    // Normalize the verb and path.
    verb = verb.toLowerCase().trim();
    path = _normalizePath(path);

    // If a route has already been defined for the given verb and path, throw
    // an error.
    assert(
        contains(verb, path) == false,
        'A route has already been defined for '
        '$verb $path');

    // If verb is not a valid HTTP verb or `all`, throw an error.
    assert(
        verb == 'all' || isHttpMethod(verb),
        'Invalid HTTP verb. '
        'Must be one of: ${httpMethods.join(', ')}, or `all`.');

    // Register the route.
    routes.add(_Route(verb, path, handler));
  }

  @override
  void use(Middleware middleware) {
    this.middleware = this.middleware?.use(middleware) ?? middleware;
  }

  @override
  void mount(String prefix, {Router? router, Handler? handler}) {
    assert(
        router != null || handler != null, 'Must provide a router or handler');
    assert(mounted.any((m) => m.segment.prefix == prefix) == false,
        'A router or handler has already been mounted at $prefix');
    if (router != null) {
      router.use(mergedMiddlewareBinder);
      return mounted.add(_MountRouter(prefix, router));
    }

    mounted.add(_MountHandler(prefix, handler!));
  }
}

abstract class _Mount {
  final _EndWithAllSegment segment;

  const _Mount(this.segment);

  /// Get the suffix of the path after the prefix.
  String suffix(String path) {
    final PrexpMatch? match = segment.match(path);
    if (match == null) return '/';

    final dynamic pathSegments = match.params[segment.param];
    if (pathSegments == null) {
      return '/';
    } else if (pathSegments is Iterable) {
      return _normalizePath(pathSegments.join('/'));
    }

    return _normalizePath(pathSegments.toString());
  }
}

class _MountRouter extends _Mount {
  final Router router;

  const _MountRouter._(super.segment, this.router);

  factory _MountRouter(String prefix, Router router) {
    return _MountRouter._(_EndWithAllSegment(prefix), router);
  }
}

class _MountHandler extends _Mount {
  final Handler handler;

  const _MountHandler._(super.segment, this.handler);

  factory _MountHandler(String prefix, Handler handler) {
    return _MountHandler._(_EndWithAllSegment(prefix), handler);
  }
}

/// Create a path segment that matches everything after path
/// segment [prefix].
class _EndWithAllSegment {
  final String prefix;
  final String param;
  final PathMatcher _matcher;

  _EndWithAllSegment._internal(this.prefix, this.param, this._matcher);

  factory _EndWithAllSegment(String prefix) {
    final String path = _normalizePath(prefix);
    final String param = '_spry_router_mount_${prefix.hashCode}';
    final Prexp prexp = Prexp.fromString('$path/:$param*');
    final PathMatcher matcher = PathMatcher.fromPrexp(prexp);

    return _EndWithAllSegment._internal(prefix, param, matcher);
  }

  /// Match the given [path] and return the matched value.
  PrexpMatch? match(String path) {
    final Iterable<PrexpMatch> matches = _matcher(path);

    return matches.isEmpty ? null : matches.first;
  }
}

class _Route {
  final String verb;
  final String path;
  final Handler handler;
  final PathMatcher _matcher;

  _Route._internal(this.verb, this.path, this.handler, this._matcher);

  factory _Route(String verb, String path, Handler handler) {
    final String normalized = _normalizePath(path);
    final Prexp prexp = Prexp.fromString(normalized);
    final PathMatcher matcher = PathMatcher.fromPrexp(prexp);

    return _Route._internal(
        verb.toLowerCase().trim(), normalized, handler, matcher);
  }

  /// Match the given [path] and return the matched value.
  PrexpMatch? match(String path) {
    final Iterable<PrexpMatch> matches = _matcher(path);

    return matches.isEmpty ? null : matches.first;
  }
}

/// Path util.
///
/// Remove ending slash from path and add a leading slash.
///
/// “/foo/bar/” => “/foo/bar”
/// “foo/bar/” => “/foo/bar”
/// “/foo/bar” => “/foo/bar”
/// ”“ => “/”
String _normalizePath(String path) {
  String normalized = path.trim();
  if (normalized.isEmpty) return '/';

  if (normalized.endsWith('/')) {
    normalized = normalized.substring(0, normalized.length - 1).trim();
  }

  if (!normalized.startsWith('/')) {
    normalized = '/$normalized';
  }

  return normalized;
}

/// Iterable extension.
extension _IterableExtension<T> on Iterable<T> {
  /// Returns the first element that satisfies the given predicate [test].
  ///
  /// Returns `null` if no element satisfies [test].
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final T element in this) {
      if (test(element)) return element;
    }

    return null;
  }
}
