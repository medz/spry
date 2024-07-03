import '../handler.dart';
import 'routes_builder.dart';

abstract interface class Router implements Handler, RoutesBuilder {
  void use(Handler handler);
}
