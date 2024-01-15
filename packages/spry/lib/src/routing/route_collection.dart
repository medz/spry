import 'routes_builder.dart';

abstract interface class RouteCollection {
  /// Initialize the [RouteCollection].
  void boot(RoutesBuilder routes);
}

extension RouteCollectionRegister on RoutesBuilder {
  /// Regsiter a [RouteCollection] to the incoming router.
  void register(RouteCollection collection) => collection.boot(this);
}
