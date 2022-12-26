import 'package:spry/spry.dart';

import '../router.dart';

class RouterImpl extends Router {
  Middleware? middleware;

  @override
  void mount(String prefix, Handler handler) {
    // TODO: implement mount
  }

  @override
  void param(String name, Middleware middleware) {
    // TODO: implement param
  }

  @override
  void route(String verb, String path, Handler handler) {
    // TODO: implement route
  }

  @override
  void use(Middleware middleware) {
    // TODO: implement use
  }
}
