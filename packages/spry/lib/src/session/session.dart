import 'internal/info.dart';
import 'session_adapter.dart';

abstract class Session {
  const factory Session({
    required SessionAdapter adapter,
    required Info info,
  }) = _SessionImpl;

  /// Returns the session identifier.
  String get identifier;

  /// Returns a stored value for the given [key].
  Future<String?> get(String key);

  /// Stores the given [value] for the given [key].
  Future<void> set(String key, String value);

  /// Returns `true` if the session contains a value for the given [key].
  Future<bool> has(String key);

  /// Removes the value for the given [key].
  Future<void> remove(String key);

  /// Destroys the session.
  ///
  /// Immediately delete all data stored by the current [Session.id]
  Future<void> destroy();

  /// Renew the session.
  ///
  /// If called, it will be rewritten to the http response header.
  Future<void> renew();
}

/// A session implementation.
class _SessionImpl implements Session {
  const _SessionImpl({
    required this.adapter,
    required this.info,
  });

  final SessionAdapter adapter;
  final Info info;

  @override
  String get identifier => info.identifier;

  @override
  Future<void> destroy() async {
    await adapter.destroy(identifier);
    await info.regenerate();
  }

  @override
  Future<String?> get(String key) => adapter.get(identifier, key);

  @override
  Future<bool> has(String key) => adapter.has(identifier, key);

  @override
  Future<void> remove(String key) => adapter.remove(identifier, key);

  @override
  Future<void> renew() {
    info.renewed = true;

    return adapter.renew(identifier);
  }

  @override
  Future<void> set(String key, String value) =>
      adapter.set(identifier, key, value);
}
