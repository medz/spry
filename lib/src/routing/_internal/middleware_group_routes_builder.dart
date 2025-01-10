import '../../types.dart';
import '../../utils.dart';
import 'group_routes_builder.dart';

final class MiddlewareGroupRoutesBuilder extends GroupRoutesBuilder {
  const MiddlewareGroupRoutesBuilder(super.routes, this.parent);

  final Middleware parent;

  @override
  void on<T>(Handler<T> handler, {String? method, String path = '/'}) {
    routes.on(parent > handler, method: method, path: path);
  }

  @override
  void use(Middleware fn, {String? method, String path = '/'}) {
    routes.use(parent | fn, method: method, path: path);
  }
}
