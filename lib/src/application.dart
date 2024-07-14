import 'package:routingkit/routingkit.dart';

import 'handler.dart';
import 'routing/routes_builder.dart';

abstract interface class Application implements RoutesBuilder {
  RouterContext<Handler> get router;
}
