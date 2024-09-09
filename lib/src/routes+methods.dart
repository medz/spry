// ignore_for_file: file_names

import 'types.dart';

/// The `<method>` extension.
extension RoutesMethods on Routes {
  /// Registers a `GET` route that responds to with the result of the [handler].
  ///
  /// ```dart
  /// app.get('/say-hello', (event) async => 'Hello, world!');
  /// ```
  void get<T>(String path, Handler<T> handler) => on<T>('GET', path, handler);

  /// Registers a `POST` route that responds to with the result of the [handler].
  ///
  /// ```dart
  /// app.post('/say/:name', (event) async => request.params.get('name'));
  /// ```
  void post<T>(String path, Handler<T> handler) => on<T>('POST', path, handler);

  /// Registers a `PUT` route that responds to with the result of the [handler].
  void put<T>(String path, Handler<T> handler) => on<T>('PUT', path, handler);

  /// Registers a `PATCH` route that responds to with the result of the [handler].
  void patch<T>(String path, Handler<T> handler) =>
      on<T>('PATCH', path, handler);

  /// Registers a `DELETE` route that responds to with the result of the [handler].
  void delete<T>(String path, Handler<T> handler) =>
      on<T>('DELETE', path, handler);

  /// Registers a `HEAD` route that responds to with the result of the [handler].
  void head<T>(String path, Handler<T> handler) => on<T>('HEAD', path, handler);
}
