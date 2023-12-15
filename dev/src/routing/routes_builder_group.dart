import 'package:routingkit/routingkit.dart';

import '_internal/routes_group.dart';
import 'routes_builder.dart';

extension RoutesBuilderGroup on RoutesBuilder {
  void group(String path, void Function(RoutesBuilder) configure) =>
      configure(grouped(path));

  RoutesBuilder grouped(String path) => RoutesGroup(this, path.pathComponents);
}
