import '../application.dart';
import '../core/container.dart';
import 'middleware_configuration.dart';
import 'route_logging_middleware.dart';

const _key = ContainerKey<MiddlewareConfiguration>(
  #spry.application.middleware_configuration,
);

extension ApplicationMiddlewareConfiguration on Application {
  MiddlewareConfiguration get middleware {
    final existing = container.get(_key);
    if (existing != null) return existing;

    final configuration = MiddlewareConfiguration();
    configuration.use(const RouteLoggingMiddleware());
    container.set(_key, value: configuration);

    return configuration;
  }

  set middleware(MiddlewareConfiguration configuration) =>
      container.set(_key, value: configuration);
}
