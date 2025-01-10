import 'package:routingkit/routingkit.dart';

import '../../types.dart';
import '../routes_builder.dart';

abstract class GroupRoutesBuilder implements RoutesBuilder {
  const GroupRoutesBuilder(this.routes);

  final RoutesBuilder routes;

  @override
  RouterContext<Handler> get router => routes.router;

  @override
  RouterContext<Middleware> get middleware => routes.middleware;
}
