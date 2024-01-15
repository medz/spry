import 'routes_builder.dart';

abstract interface class RouteCollection {
  /// Initialize the [RouteCollection].
  void initializeRoutes(RoutesBuilder routes);
}

extension RouteCollectionRegister on RoutesBuilder {
  /// Regsiter a [RouteCollection] to the incoming router.
  void register(RouteCollection collection) =>
      collection.initializeRoutes(this);
}
