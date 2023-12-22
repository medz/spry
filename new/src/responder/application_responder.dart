import '../application.dart';
import '../utilities/storage.dart';

extension ApplicationResponderProperties on Application {
  /// Returns the application's responder.
  ApplicationResponder get responder {
    final existing = storage.get(const StorageKey<ApplicationResponder>());
    if (existing != null) return existing;

    return storage.set(
      const StorageKey<ApplicationResponder>(),
      ApplicationResponder(this),
    );
  }
}

class ApplicationResponder {
  final Application application;

  const ApplicationResponder(this.application);
}
