import '../application.dart';
import '../commands/serve_command.dart';
import '../utilities/storage.dart';
import 'server.dart';

extension ApplicationServersProperty on Application {
  /// Returns the application servers.
  ApplicationServers get servers {
    final existing = storage.get(const StorageKey<ApplicationServers>());
    if (existing != null) return existing;

    return storage.set(
      const StorageKey<ApplicationServers>(),
      ApplicationServers(application: this),
    );
  }

  /// Returns current maked server.
  Server get server {
    final factory = servers._storage.makeServer.factory;
    if (factory != null) return factory(this);

    throw StateError(
        'No server configured. Configure with app.servers.use(...)');
  }
}

class ApplicationServers {
  final Application application;

  const ApplicationServers({required this.application});

  /// Initializes the application servers.
  void initialize() {
    application.storage.set(const _Key(), _Storage());
  }

  /// Internal, Returns the servers storage.
  _Storage get _storage {
    final existing = application.storage.get(const _Key());
    if (existing != null) return existing;

    throw StateError(
        'Servers not initialized. Configure with app.servers.initialize()');
  }

  /// Returns the application serve command.
  ServeCommand get command {
    final existing = application.storage.get(const _CommandKey());
    if (existing != null) return existing;

    return application.storage.set(const _CommandKey(), ServeCommand());
  }

  /// Use a closure to create a server.
  void use(Server Function(Application application) factory) {
    _storage.makeServer.factory = factory;
  }

  /// Use a provider to configure a server.
  void provider(ApplicationServersProvider provider) =>
      provider.run(application);
}

class ApplicationServersProvider {
  final void Function(Application application) run;

  const ApplicationServersProvider({required this.run});
}

typedef _Key = StorageKey<_Storage>;
typedef _CommandKey = StorageKey<ServeCommand>;

class _Storage {
  _ServerFactory makeServer;

  _Storage([_ServerFactory? makeServer])
      : makeServer = makeServer ?? _ServerFactory();
}

class _ServerFactory {
  Server Function(Application application)? factory;

  _ServerFactory();
}
