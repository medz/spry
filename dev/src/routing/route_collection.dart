import 'routes_builder.dart';

abstract interface class RouteCollection {
  /// Register routes to the incoming router.
  void setupRoutes(RoutesBuilder routes);
}

extension RouteCollectionRegister on RoutesBuilder {
  /// Registers all of the routes in the given [collection] to the router.
  void register(RouteCollection collection) => collection.setupRoutes(this);
}
