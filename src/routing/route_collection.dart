import 'routes_builder.dart';

abstract interface class RouteCollection {
  /// Registers routes to the incoming router.
  void register(RoutesBuilder routes);
}

extension RouteCollectionRegister on RoutesBuilder {
  /// Regsiter a [RouteCollection] to the incoming router.
  void register(RouteCollection collection) => collection.register(this);
}
