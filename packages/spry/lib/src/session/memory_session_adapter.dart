import 'dart:async';
import 'dart:collection';

import 'session_adapter.dart';

/// Memory-based session adapter.
class MemorySessionAdapter extends SessionAdapter {
  /// Global momory session managers
  static final Map<String, _MomorySessionManager> _managers = {};

  const MemorySessionAdapter({
    super.expiration = const Duration(minutes: 20),
  });

  @override
  Future<void> destroy(String identifier) async {
    return _manager(identifier).destroy();
  }

  @override
  Future<String?> get(String identifier, String key) async {
    return _manager(identifier).get(key);
  }

  @override
  Future<bool> has(String identifier, String key) async {
    return _manager(identifier).has(key);
  }

  @override
  Future<void> remove(String identifier, String key) async {
    return _manager(identifier).remove(key);
  }

  @override
  Future<void> set(String identifier, String key, String value) async {
    return _manager(identifier).set(key, value);
  }

  @override
  Future<bool> can(String identifier) async {
    return _managers.containsKey(identifier);
  }

  @override
  Future<void> renew(String identifier) async {
    return _manager(identifier).renew();
  }

  /// Resolve the session manager
  _MomorySessionManager _manager(String identifier) {
    if (_managers.containsKey(identifier)) {
      return _managers[identifier]!;
    }

    return _managers[identifier] = _createManager(identifier);
  }

  /// Create a new session manager
  _MomorySessionManager _createManager(String identifier) {
    final manager = _MomorySessionManager(
      expiration: expiration,
      onTimeout: () => onTimeout(identifier),
    );

    return _managers[identifier] = manager;
  }

  /// On timeout callback of the session manager
  void onTimeout(String identifier) => _managers.remove(identifier);

  @override
  Future<DateTime?> expiresAt(String identifier) =>
      _manager(identifier).expiresAt();
}

class _MomorySessionManager {
  _MomorySessionManager({
    required this.expiration,
    required this.onTimeout,
  }) {
    renew();
  }

  final Map<String, String> _data = HashMap();
  Timer? timer;
  DateTime? startedAt;

  final Duration expiration;
  final void Function() onTimeout;

  /// Returns a session value.
  String? get(String key) {
    return _data[key];
  }

  /// Sets a session value.
  void set(String key, String value) {
    _data[key] = value;
  }

  /// Returns `true` if the session contains a value for the given [key].
  bool has(String key) => _data.containsKey(key);

  /// Removes a session value.
  void remove(String key) {
    _data.remove(key);
  }

  /// Statrt the session timer
  void _start() {
    _stop();
    timer = Timer(expiration, onTimeout);
    startedAt = DateTime.now();
  }

  /// Stop the session timer
  void _stop() {
    timer?.cancel();
    timer = null;
    startedAt = null;
  }

  /// Renew the session
  void renew() {
    if (expiration == Duration.zero) {
      return;
    }

    _start();
  }

  /// Destroy the session
  void destroy() {
    _stop();
    _data.clear();
    onTimeout();
  }

  /// Returns the session expires at.
  Future<DateTime?> expiresAt() async {
    if (startedAt == null) {
      return null;
    }

    return startedAt!.add(expiration);
  }
}
