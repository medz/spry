import '../application.dart';

abstract class Server {
  final Application application;

  const Server(this.application);

  Future<void> get onShutdown;

  /// Start the server with the specified address.
  Future<void> start();

  /// Stop the server.
  Future<void> shutdown();
}
