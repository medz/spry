/// WebSocket's ready state.
extension type const ReadyState(int code) implements int {
  /// Unknown ready state.
  static const unknown = ReadyState(-1);

  /// Connecting ready state.
  static const connecting = ReadyState(0);

  /// Open ready state.
  static const open = ReadyState(1);

  /// Closing ready state.
  static const closing = ReadyState(2);

  /// Closed ready state.
  static const closed = ReadyState(3);
}
