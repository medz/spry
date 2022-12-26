import 'package:spry/spry.dart';

import 'route.dart';

/// A spry [Router] routes to handlers based on HTTP verb and path.
///
/// ```dart
/// final spry = Spry();
/// final router = Router();
///
/// // Create a hello route.
/// router.get('/hello/:name', (Context context) {
///   final String name = context.request.params['name'];
///
///   context.response.send('Hello $name!');
/// });
///
/// await spry.listen(router, port: 3000);
/// ```
///
/// If multiple routes match a request, the first route is used.
abstract class Router {
  /// Add a [Middleware] to the router.
  ///
  /// ```dart
  /// router.use((Context context, MiddlewareNext next) {
  ///   // Do something.
  ///   return next();
  /// });
  /// ```
  void use(Middleware middleware);

  /// Adds a [Middleware] to route parameters.
  ///
  /// ```dart
  /// router.param('id', (Context context, MiddlewareNext next) async {
  ///  final String id = context.request.params['id'];
  ///
  ///  // Do something with id.
  ///  await next();
  /// });
  /// ```
  void param(String name, Middleware middleware);

  /// Mount a [Handler] below a [prefix].
  Route mount(String prefix, Handler handler);

  /// Add a [handler] for HTTP [verb] requests to [path].
  Route route(String verb, String path, Handler handler);

  /// Handle all HTTP verbs for a [path].
  Route all(String path, Handler handler) => route('all', path, handler);

  /// Handle HTTP GET requests for a [path].
  Route get(String path, Handler handler) => route('get', path, handler);

  /// Handle HTTP POST requests for a [path].
  Route post(String path, Handler handler) => route('post', path, handler);

  /// Handle HTTP PUT requests for a [path].
  Route put(String path, Handler handler) => route('put', path, handler);

  /// Handle HTTP PATCH requests for a [path].
  Route patch(String path, Handler handler) => route('patch', path, handler);

  /// Handle HTTP DELETE requests for a [path].
  Route delete(String path, Handler handler) => route('delete', path, handler);

  /// Handle HTTP HEAD requests for a [path].
  Route head(String path, Handler handler) => route('head', path, handler);

  /// Handle HTTP OPTIONS requests for a [path].
  Route options(String path, Handler handler) =>
      route('options', path, handler);

  /// Handle HTTP CONNECT requests for a [path].
  Route connect(String path, Handler handler) =>
      route('connect', path, handler);

  /// Handle HTTP TRACE requests for a [path].
  Route trace(String path, Handler handler) => route('trace', path, handler);
}
