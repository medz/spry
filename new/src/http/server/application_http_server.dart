import '../../application.dart';
import '../../utilities/storage.dart';
import '../application_http.dart';
import 'http_server_configuration.dart';

extension ApplicationHTTPProperties on ApplicationHTTP {
  /// Returns the application's HTTP server.
  ApplicationHTTPServer get server {
    final existing = application.storage.get(
      const StorageKey<ApplicationHTTPServer>(),
    );
    if (existing != null) return existing;

    return application.storage.set(
      const StorageKey<ApplicationHTTPServer>(),
      ApplicationHTTPServer(application),
    );
  }
}

class ApplicationHTTPServer {
  final Application _application;

  const ApplicationHTTPServer(Application application)
      : _application = application;

  /// Returns the application's HTTP server configuration.
  HTTPServerConfiguration get configuration {
    final existing =
        _application.storage.get(const StorageKey<HTTPServerConfiguration>());
    if (existing != null) return existing;

    return _application.storage.set(
      const StorageKey<HTTPServerConfiguration>(),
      HTTPServerConfiguration(),
    );
  }
}
