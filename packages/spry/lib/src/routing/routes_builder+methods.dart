// ignore_for_file: file_names

import 'dart:async';
import 'dart:io';

import 'routes_builder.dart';
import 'routes_builder+closure.dart';

extension RoutesBuilder$Methods on RoutesBuilder {
  /// Registers a `GET` route that responds to with the result of the [closure].
  ///
  /// ```dart
  /// app.get('/say-hello', (request) async => 'Hello, world!');
  /// ```
  void get<T>(String path, FutureOr<T> Function(HttpRequest request) closure) =>
      on(closure, method: 'GET', path: path);

  /// Registers a `POST` route that responds to with the result of the
  /// [closure].
  ///
  /// ```dart
  /// app.post('/say/:name', (request) async => request.params.get('name'));
  /// ```
  void post<T>(
          String path, FutureOr<T> Function(HttpRequest request) closure) =>
      on(closure, method: 'POST', path: path);

  /// Registers a `PUT` route that responds to with the result of the [closure].
  void put<T>(String path, FutureOr<T> Function(HttpRequest request) closure) =>
      on(closure, method: 'PUT', path: path);

  /// Registers a `PATCH` route that responds to with the result of the
  /// [closure].
  void patch<T>(
          String path, FutureOr<T> Function(HttpRequest request) closure) =>
      on(closure, method: 'PATCH', path: path);

  /// Registers a `DELETE` route that responds to with the result of the
  /// [closure].
  void delete<T>(
          String path, FutureOr<T> Function(HttpRequest request) closure) =>
      on(closure, method: 'DELETE', path: path);

  /// Registers a `HEAD` route that responds to with the result of the
  /// [closure].
  void head<T>(
          String path, FutureOr<T> Function(HttpRequest request) closure) =>
      on(closure, method: 'HEAD', path: path);
}
