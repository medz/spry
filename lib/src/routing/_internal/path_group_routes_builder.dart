import '../../types.dart';
import 'group_routes_builder.dart';

final class PathGroupRoutesBuilder extends GroupRoutesBuilder {
  const PathGroupRoutesBuilder(super.routes, this.prefix);

  final String prefix;

  @override
  void on<T>(Handler<T> handler, {String? method, String path = '/'}) {
    routes.on(handler, method: method, path: '$prefix/$path');
  }

  @override
  void use(Middleware fn, {String? method, String path = '/'}) {
    routes.use(fn, method: method, path: '$prefix/$path');
  }
}
