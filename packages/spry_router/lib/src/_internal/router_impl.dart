part of '../router.dart';

const String __spryRouterPrefix = '__spry_router';
const String __spryRouterDelimiter = '/';

class _RouterImpl extends Router {
  @override
  final String prefix;

  Middleware? middleware;

  final PathMatcher matcher;

  final Map<String, ParamMiddleware> paramMiddleware = {};
  final List<RouteImpl> routes = [];
  final Map<String, _RouterImpl> nested = {};

  _RouterImpl._internal(this.prefix, this.matcher) : super._internal();

  factory _RouterImpl() {
    return _RouterImpl._internal(
        '', PathMatcher.fromPrexp(Prexp.fromString('/')));
  }

  @override
  Route mount(String prefix, Handler handler) =>
      all(_createMountPath(this.prefix, prefix), handler);

  static String _createMountPath(String prefix, String path) {
    // Create full prefix path name, format: "{__spryRouterMountPrefix}_{hash}"
    final String name = '${__spryRouterPrefix}_${(prefix + path).hashCode}';

    // Create a route path for the full prefix.
    return '${_resolvePath(path)}$__spryRouterDelimiter:$name*';
  }

  @override
  void param(String name, ParamMiddleware middleware) {
    paramMiddleware[name] =
        paramMiddleware[name]?.use(middleware) ?? middleware;
  }

  @override
  Route route(String verb, String path, Handler handler) {
    String resolvedPath = _resolvePath(path);
    String fullPath = prefix + resolvedPath;
    final String resolvedVerb = verb.toLowerCase();

    // If resolve starts not with delimiter, add it.
    if (!fullPath.startsWith(__spryRouterDelimiter)) {
      fullPath = __spryRouterDelimiter + resolvedPath;
    }

    // Create a route.
    final RouteImpl route = RouteImpl(
      path: resolvedPath,
      fullPath: fullPath,
      verb: resolvedVerb,
      handler: handler,
    );

    // If verb is "all", add it
    if (route.verb == 'all') {
      routes.add(route);

      return route;
    }

    // If verb is not a supported http verb, throw an error.
    if (!isHttpMethod(resolvedVerb)) {
      throw ArgumentError.value(verb, 'verb', 'Unsupported HTTP verb.');
    }

    // Add the route.
    routes.add(route);

    return route;
  }

  @override
  void use(Middleware middleware) {
    this.middleware = this.middleware?.use(middleware) ?? middleware;
  }

  @override
  FutureOr<void> call(Context context) {
    final String requestPath = context.request.uri.path;
    final String verb = context.request.method.toLowerCase();

    // Verb routes.
    final Iterable<Route> verbRoutes =
        routes.where((route) => route.verb == verb);
    for (final Route route in verbRoutes) {
      final PrexpMatch? match = route.match(requestPath);
      if (match != null) {
        return _handleRoute(context, route, match);
      }
    }

    // All routes.
    final Iterable<Route> allRoutes =
        routes.where((route) => route.verb == 'all');
    for (final Route route in allRoutes) {
      final PrexpMatch? match = route.match(requestPath);
      if (match != null) {
        return _handleRoute(context, route, match);
      }
    }

    // Nested routers.
    for (final _RouterImpl router in nested.values) {
      final Iterable<PrexpMatch> matches = router.matcher(requestPath);
      if (matches.isNotEmpty) {
        print(router.prefix);
        return _handleRoute(context, router, matches.first);
      }
    }

    // Not found.
    throw HttpException.notFound();
  }

  /// Handle route.
  FutureOr<void> _handleRoute(
      Context context, Handler handler, PrexpMatch match) async {
    final Map<String, Object?> params = _getOrCreateParams(context);
    final Map<String, Object?> routeParams = match.params;

    for (final MapEntry<String, dynamic> param in routeParams.entries) {
      // Set route param to context.
      params[param.key] = param.value;

      // Find param middleware.
      final ParamMiddleware? middleware = paramMiddleware[param.key];
      if (middleware != null) {
        // Create param middleware next function.
        next(Object? value) {
          params[param.key] = value;
        }

        // Call middleware.
        await middleware(context, param.value, next);
      }
    }

    final Middleware middleware = this.middleware ?? emptyMiddleware;

    // Call middleware.
    return middleware(context, () => handler(context));
  }

  /// Resolve route path.
  ///
  /// If [path] starts not with delimiter, add it.
  /// If [path] ends with delimiter, remove it.
  ///
  /// Example:
  ///   "/" => ""
  ///   "/hello" => "/hello"
  ///   "/hello/" => "/hello"
  static String _resolvePath(String path) {
    String resolvedPath = path.trim();

    // If path starts not with delimiter, add it.
    if (!resolvedPath.startsWith(__spryRouterDelimiter)) {
      resolvedPath = __spryRouterDelimiter + resolvedPath;
    }

    // If path ends with delimiter, remove it.
    if (resolvedPath.endsWith(__spryRouterDelimiter)) {
      resolvedPath = resolvedPath.substring(
          0, resolvedPath.length - __spryRouterDelimiter.length);
    }

    return resolvedPath;
  }

  /// Get or create params map.
  static Map<String, Object?> _getOrCreateParams(Context context) {
    final Object? params = context.get(SPRY_REQUEST_PARAMS);
    if (params is Map<String, Object?>) {
      return params;
    }

    final Map<String, Object?> newParams = {};
    context.set(SPRY_REQUEST_PARAMS, newParams);

    return newParams;
  }

  @override
  _RouterImpl copyWith({String? fillPrefix}) {
    final String path = fillPrefix ?? prefix;
    final _RouterImpl router = _RouterImpl._internal(
      path,
      PathMatcher.fromPrexp(Prexp.fromString(_createMountPath('', path))),
    );
    router.middleware = middleware;
    router.paramMiddleware.addAll(paramMiddleware);

    // Routes.
    for (final RouteImpl route in routes) {
      final Route newRoute =
          router.route(route.verb, route.path, route.handler);

      if (route.middleware != null) {
        newRoute.use(route.middleware!);
      }

      for (final MapEntry<String, ParamMiddleware> entry
          in route.paramMiddleware.entries) {
        newRoute.param(entry.key, entry.value);
      }
    }

    // Nested
    for (final MapEntry<String, _RouterImpl> entry in nested.entries) {
      router.nest(entry.key, entry.value);
    }

    return router;
  }

  @override
  void nest(String prefix, Router router) {
    final String fullPrefix = this.prefix + _resolvePath(prefix);

    nested[prefix] = router.copyWith(fillPrefix: fullPrefix) as _RouterImpl;
  }

  @override
  Iterable<String> dump() {
    final List<String> result = [];

    result.addAll(routes.map((route) => '${route.verb} - ${route.fullPath}'));

    for (final _RouterImpl router in nested.values) {
      result.addAll(router.dump());
    }

    return result;
  }
}
