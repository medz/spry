import 'dart:io';

abstract interface class Server {
  Future<void> get onShutdown;

  /// Start the server with the specified address.
  Future<void> start(InternetAddress address);

  /// Stop the server.
  Future<void> shutdown();
}
