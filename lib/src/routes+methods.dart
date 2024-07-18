// ignore_for_file: file_names

import 'types.dart';

/// The `<method>` extension.
extension RoutesMethods on Routes {
  /// Registers a `GET` route that responds to with the result of the [closure].
  ///
  /// ```dart
  /// app.get('/say-hello', (event) async => 'Hello, world!');
  /// ```
  void get<T>(String path, Handler<T> handler) => on('GET', path, handler);

  /// Registers a `POST` route that responds to with the result of the [closure].
  ///
  /// ```dart
  /// app.post('/say/:name', (event) async => request.params.get('name'));
  /// ```
  void post<T>(String path, Handler<T> handler) => on('POST', path, handler);

  /// Registers a `PUT` route that responds to with the result of the [closure].
  void put<T>(String path, Handler<T> handler) => on('PUT', path, handler);

  /// Registers a `PATCH` route that responds to with the result of the [closure].
  void patch<T>(String path, Handler<T> handler) => on('PATCH', path, handler);

  /// Registers a `DELETE` route that responds to with the result of the [closure].
  void delete<T>(String path, Handler<T> handler) =>
      on('DELETE', path, handler);

  /// Registers a `HEAD` route that responds to with the result of the [closure].
  void head<T>(String path, Handler<T> handler) => on('HEAD', path, handler);
}
