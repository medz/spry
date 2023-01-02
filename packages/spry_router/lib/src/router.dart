import 'dart:async';
import 'dart:io';

import 'package:http_methods/http_methods.dart';
import 'package:prexp/prexp.dart';
import 'package:spry/spry.dart';
import 'package:spry/extension.dart';

import '_internal/constants.dart';
import '_internal/empty_functions.dart';
import '_internal/param_middleware_extension.dart';
import '_internal/route_impl.dart';
import 'param_middleware.dart';
import 'route.dart';

part '_internal/router_impl.dart';

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
  const Router._internal();

  /// Create a new [Router].
  factory Router([String prefix = '/']) => _RouterImpl(prefix);

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
  void param(String name, ParamMiddleware middleware);

  /// Cast the router to a [Handler].
  ///
  /// ```dart
  /// final spry = Spry();
  /// final router = Router();
  ///
  /// router.get('/hello', (Context context) {
  ///  context.response.send('Hello World!');
  /// });
  ///
  /// await spry.listen(router, port: 3000);
  /// ```
  FutureOr<void> call(Context context);

  /// Mount a [Handler] below a [prefix].
  Route mount(Handler handler, {String? prefix});

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
