// ignore_for_file: file_names

import 'dart:async';

import '../event/event.dart';
import 'routes_builder.dart';
import 'routes_builder+on.dart';

extension RoutesBuildrMethods on RoutesBuilder {
  void get<T>(String route, FutureOr<T> Function(Event event) closure) {
    on('GET', route, closure);
  }

  void post<T>(String route, FutureOr<T> Function(Event event) closure) {
    on('POST', route, closure);
  }

  void put<T>(String route, FutureOr<T> Function(Event event) closure) {
    on('PUT', route, closure);
  }

  void patch<T>(String route, FutureOr<T> Function(Event event) closure) {
    on('PATCH', route, closure);
  }

  void delete<T>(String route, FutureOr<T> Function(Event event) closure) {
    on('DELETE', route, closure);
  }

  void head<T>(String route, FutureOr<T> Function(Event event) closure) {
    on('HEAD', route, closure);
  }
}
