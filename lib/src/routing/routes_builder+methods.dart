// ignore_for_file: file_names

import '../handler.dart';
import '_routing_keys.dart';
import 'routes_builder.dart';

extension RoutesBuilderMethods on RoutesBuilder {
  void all(String route, Handler handler) => on(kAllMethod, route, handler);
  void get(String route, Handler handler) => on('GET', route, handler);
  void post(String route, Handler handler) => on('POST', route, handler);
  void put(String route, Handler handler) => on('PUT', route, handler);
  void patch(String route, Handler handler) => on('PATCH', route, handler);
  void delete(String route, Handler handler) => on('DELETE', route, handler);
  void head(String route, Handler handler) => on('HEAD', route, handler);
}
