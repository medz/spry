import '../application.dart';
import 'middleware_configuration.dart';

extension ApplicationMiddlewareConfiguration on Application {
  MiddlewareConfiguration get middleware =>
      injectOrProvide(MiddlewareConfiguration, MiddlewareConfiguration.new);
}
