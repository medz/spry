import '../application.dart';
import 'route.dart';
import 'routes_builder.dart';

final class Routes implements RoutesBuilder {
  final List<Route> _routes = [];

  Iterable<Route> get all => _routes;
  int defaultMaxBodySize = 1024 * 1024 * 10; // 10 MB
  bool caseInsensitive = false;

  String get description => all.map((e) => e.description).join('\n');

  @override
  void add(Route route) => _routes.add(route);
}

extension ApplicationRoutes on Application {
  Routes get routes => injectOrProvide(Routes, Routes.new);
}
