import '../application.dart';
import 'routes.dart';

extension ApplicationRoutes on Application {
  Routes get routes => injectOrProvide(Routes, Routes.new);
}
