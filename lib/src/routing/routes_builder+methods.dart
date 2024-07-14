// ignore_for_file: file_names

import '../handler.dart';
import 'routes_builder.dart';

extension RoutesBuildrMethods on RoutesBuilder {
  /// Registers a `GET` route that responds to with the result of the [closure].
  ///
  /// ```dart
  /// app.get('/say-hello', (request) async => 'Hello, world!');
  /// ```
  void get<T>(String route, Handler handler) {
    on('GET', route, handler);
  }

//   /// Registers a `POST` route that responds to with the result of the [closure].
//   ///
//   /// ```dart
//   /// app.post('/say/:name', (request) async => request.params.get('name'));
//   /// ```
//   void post<T>(String route, FutureOr<T> Function(Event event) closure) {
//     on('POST', route, closure);
//   }

//   /// Registers a `PUT` route that responds to with the result of the [closure].
//   void put<T>(String route, FutureOr<T> Function(Event event) closure) {
//     on('PUT', route, closure);
//   }

//   /// Registers a `PATCH` route that responds to with the result of the [closure].
//   void patch<T>(String route, FutureOr<T> Function(Event event) closure) {
//     on('PATCH', route, closure);
//   }

//   /// Registers a `DELETE` route that responds to with the result of the [closure].
//   void delete<T>(String route, FutureOr<T> Function(Event event) closure) {
//     on('DELETE', route, closure);
//   }

//   /// Registers a `HEAD` route that responds to with the result of the [closure].
//   void head<T>(String route, FutureOr<T> Function(Event event) closure) {
//     on('HEAD', route, closure);
//   }
}
