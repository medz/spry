// ignore_for_file: file_names

import 'types.dart';
import 'utils/_create_chain_handler.dart';

extension RoutesGroup on Routes {
  Routes grouped({String? path, Iterable<Handler>? uses}) {
    Routes routes = this;

    if (path != null && path.isNotEmpty) {
      routes = _PrefixRoutes(routes, path);
    }

    if (uses != null && uses.isNotEmpty) {
      routes = _StackRoutes(routes, uses.toList(growable: false).reversed);
    }

    return routes;
  }

  Routes group(void Function(Routes routes) fn,
      {String? path, Iterable<Handler>? uses}) {
    final routes = grouped(path: path, uses: uses);

    fn(routes);

    return routes;
  }
}

class _PrefixRoutes implements Routes {
  const _PrefixRoutes(this.root, this.prefix);

  final Routes root;
  final String prefix;

  @override
  void on<T>(String? method, String path, Handler<T> handler) {
    root.on<T>(method, '$prefix/$path', handler);
  }
}

class _StackRoutes implements Routes {
  const _StackRoutes(this.root, this.uses);

  final Routes root;
  final Iterable<Handler> uses;

  @override
  void on<T>(String? method, String path, Handler<T> handler) {
    root.on(method, path, createChainHandler(uses, handler));
  }
}
