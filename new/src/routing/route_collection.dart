import 'routes_builder.dart';

abstract interface class RouteCollection {
  /// Registers routes to the incoming router.
  void setupRoutes(RoutesBuilder routes);
}

extension RouteCollectionRegister on RoutesBuilder {
  /// Regsiter a [RouteCollection] to the incoming router.
  void collection(RouteCollection collection) => collection.setupRoutes(this);
}
