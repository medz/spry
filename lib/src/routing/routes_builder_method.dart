import '../types.dart';
import 'routes_builder.dart';

extension RoutesBuilderMethod on RoutesBuilder {
  /// Listen a get request.
  void get<T>(String path, Handler<T> handler) =>
      on(method: 'GET', path: path, handler);

  /// Listen a head request.
  void head<T>(String path, Handler<T> handler) =>
      on(method: 'HEAD', path: path, handler);

  // Listen a post request.
  void post<T>(String path, Handler<T> handler) =>
      on(method: 'POST', path: path, handler);

  /// Listen a patch request.
  void patch<T>(String path, Handler<T> handler) =>
      on(method: 'PATCH', path: path, handler);

  /// Listen a put request.
  void put<T>(String path, Handler<T> handler) =>
      on(method: 'PUT', path: path, handler);

  /// listen a delete request.
  void delete<T>(String path, Handler<T> handler) =>
      on(method: 'DELETE', path: path, handler);
}
