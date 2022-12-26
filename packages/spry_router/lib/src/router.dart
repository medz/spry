import 'package:spry/spry.dart';

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

  /// Mount a [Handler] below a [prefix].
  void mount(String prefix, Handler handler);

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

  /// Add a [handler] for HTTP [verb] requests to [path].
  void route(String verb, String path, Handler handler);

  /// Handle all HTTP verbs for a [path].
  void all(String path, Handler handler) => route('all', path, handler);

  /// Handle HTTP GET requests for a [path].
  void get(String path, Handler handler) => route('get', path, handler);

  /// Handle HTTP POST requests for a [path].
  void post(String path, Handler handler) => route('post', path, handler);

  /// Handle HTTP PUT requests for a [path].
  void put(String path, Handler handler) => route('put', path, handler);

  /// Handle HTTP PATCH requests for a [path].
  void patch(String path, Handler handler) => route('patch', path, handler);

  /// Handle HTTP DELETE requests for a [path].
  void delete(String path, Handler handler) => route('delete', path, handler);

  /// Handle HTTP HEAD requests for a [path].
  void head(String path, Handler handler) => route('head', path, handler);

  /// Handle HTTP OPTIONS requests for a [path].
  void options(String path, Handler handler) => route('options', path, handler);

  /// Handle HTTP CONNECT requests for a [path].
  void connect(String path, Handler handler) => route('connect', path, handler);

  /// Handle HTTP TRACE requests for a [path].
  void trace(String path, Handler handler) => route('trace', path, handler);
}
