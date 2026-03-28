import 'base_client.dart';

/// Shared base for generated route helper types.
class ClientRoutes {
  /// Creates a route helper shell bound to a generated client.
  const ClientRoutes(this.client);

  /// Generated client runtime used by this route helper.
  final BaseSpryClient client;
}
