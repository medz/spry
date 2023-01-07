import 'package:spry/spry.dart';

import 'router.dart';

/// HTTP verb define a route extension.
///
// 'GET',
// 'HEAD',
// 'POST',
// 'PUT',
// 'DELETE',
// 'CONNECT',
// 'OPTIONS',
// 'TRACE',
extension HttpVerbRouterExtension on Router {
  /// Define a `all` route.
  void all(String path, Handler handler) => route(r'all', path, handler);

  /// Define a `get` route.
  void get(String path, Handler handler) => route(r'get', path, handler);

  /// Define a `head` route.
  void head(String path, Handler handler) => route(r'head', path, handler);

  /// Define a `post` route.
  void post(String path, Handler handler) => route(r'post', path, handler);

  /// Define a `put` route.
  void put(String path, Handler handler) => route(r'put', path, handler);

  /// Define a `delete` route.
  void delete(String path, Handler handler) => route(r'delete', path, handler);

  /// Define a `connect` route.
  void connect(String path, Handler handler) =>
      route(r'connect', path, handler);

  /// Define a `options` route.
  void options(String path, Handler handler) =>
      route(r'options', path, handler);

  /// Define a `trace` route.
  void trace(String path, Handler handler) => route(r'trace', path, handler);
}
