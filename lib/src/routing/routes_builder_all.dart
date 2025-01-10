import '../types.dart';
import 'routes_builder.dart';

extension RoutesBuilderAll on RoutesBuilder {
  /// Listen all request on the handler.
  void all<T>(String path, Handler<T> handler) => on(path: path, handler);
}
