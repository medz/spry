import 'package:meta/meta.dart';

import '../application.dart';
import '../utilities/storage.dart';

class ApplicationHTTP {
  @internal
  final Application application;

  const ApplicationHTTP(this.application);
}

extension ApplicationHTTPProperty on Application {
  /// Returns the application HTTP.
  ApplicationHTTP get http {
    final existing = storage.get(const StorageKey<ApplicationHTTP>());
    if (existing != null) return existing;

    return storage.set(
      const StorageKey<ApplicationHTTP>(),
      ApplicationHTTP(this),
    );
  }
}
