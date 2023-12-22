// ignore_for_file: file_names

import '../application.dart';
import 'default_server.dart';
import 'server.dart';
import 'servers.dart';

extension Application$Servers on Application {
  /// Returns spry servers configuration.
  Servers get servers {
    final existing = container.get<Servers>();
    if (existing != null) return existing;

    final servers = Servers(this);
    container.set(servers, onShutdown: (servers) => servers.current.shutdown());

    // Set default server.
    servers.use(DefaultServer.new);

    return servers;
  }

  /// Returns current configured server.
  Server get server => servers.current;
}
