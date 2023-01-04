part of '../router.dart';

const String __spryRouterPrefix = '__spry_router';
const String __spryRouterDelimiter = '/';

class _RouterImpl extends Router {
  final String prefix;

  Middleware? middleware;

  final Map<String, ParamMiddleware> paramMiddleware = {};
  final List<Route> routes = [];

  _RouterImpl._internal(this.prefix) : super._internal();

  factory _RouterImpl([String prefix = '/']) {
    return _RouterImpl._internal(_resolvePath(prefix));
  }

  @override
  Route mount(Handler handler, {String? prefix}) {
    // Handler is a router, prefix must be null or empty.
    if (handler is Router && prefix != null && prefix.isNotEmpty) {
      throw ArgumentError.value(
          prefix, 'prefix', 'Cannot mount a router with a prefix.');
    }

    // Create a resolved full prefix.
    final String fullPrefix = this.prefix + (prefix ?? '');

    // Create full prefix path name, format: "{__spryRouterMountPrefix}_{hash}"
    final String name = '${__spryRouterPrefix}_${fullPrefix.hashCode}';

    // Create a route path for the full prefix.
    final String path = '$fullPrefix$__spryRouterDelimiter:$name*';

    // Bind the handler to the route path match all http verbs.
    return all(path, handler);
  }

  @override
  void param(String name, ParamMiddleware middleware) {
    paramMiddleware[name] =
        paramMiddleware[name]?.use(middleware) ?? middleware;
  }

  @override
  Route route(String verb, String path, Handler handler) {
    String resolvedPath = prefix + _resolvePath(path);
    final String resolvedVerb = verb.toLowerCase();

    // If resolve starts not with delimiter, add it.
    if (!resolvedPath.startsWith(__spryRouterDelimiter)) {
      resolvedPath = __spryRouterDelimiter + resolvedPath;
    }

    // Create a route.
    final Route route = RouteImpl(resolvedVerb, resolvedPath, handler);

    // If verb is "all", add it
    if (route.verb == 'all') {
      routes.add(route);

      return route;
    }

    // If verb is not a supported http verb, throw an error.
    if (!isHttpMethod(resolvedVerb)) {
      throw ArgumentError.value(verb, 'verb', 'Unsupported HTTP verb.');
    }

    // If verb is a "get", add a "head" route.
    //
    // Handling in a 'GET' request without handling a 'HEAD' request is always
    // wrong, thus, we add a default implementation that discards the body.
    if (resolvedVerb == 'get') {
      routes.add(RouteImpl('head', resolvedPath, _defaultHeadHandler));
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

    // Not found.
    throw HttpException.notFound();
  }

  /// Handle route.
  FutureOr<void> _handleRoute(
      Context context, Route route, PrexpMatch match) async {
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
    return middleware(context, () => route(context));
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

  /// Default head handler.
  static FutureOr<void> _defaultHeadHandler(Context context) {
    context.response
      ..status(HttpStatus.ok)
      ..headers.contentLength = 0;
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
}
