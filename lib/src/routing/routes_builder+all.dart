// ignore_for_file: file_names

import '../handler.dart';
import 'routes_builder.dart';

extension RoutesBuilderAll on RoutesBuilder {
  /// Spry all request method.
  static const kAllMethod = '#SPRY/__ALL__';

  /// adds a all request method route.
  void all<T>(String route, Handler handler) {
    return on(kAllMethod, route, handler);
  }
}
