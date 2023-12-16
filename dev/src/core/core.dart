import '../application.dart';
import 'container.dart';

const _containerKey = ContainerKey<CoreContainer>(#spry.core.container);

class Core {
  final Application _application;

  const Core(Application application) : _application = application;

  CoreContainer get container {
    final existing = _application.container.get(_containerKey);
    if (existing != null) {
      return existing;
    }

    throw StateError('Core not configured. Configure with app.core.setup()');
  }

  /// Setups the core.
  void setup() {
    _application.container
        .set(_containerKey, value: CoreContainer(_application));
  }
}

class CoreContainer {
  final Application _application; // ignore: unused_field

  const CoreContainer(this._application);
}
