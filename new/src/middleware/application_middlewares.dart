import '../application.dart';
import '../utilities/storage.dart';
import 'middlewares.dart';

typedef _Key = StorageKey<Middlewares>;

extension ApplicationMiddlewares on Application {
  /// Returns the configured middleware stack.
  Middlewares get middleware {
    return switch (storage.get(const _Key())) {
      Middlewares value => value,
      _ => storage.set(const _Key(), Middlewares()),
    };
  }

  /// Sets a new middleware stack.
  set middleware(Middlewares value) {
    storage.set(const _Key(), value);
  }
}
