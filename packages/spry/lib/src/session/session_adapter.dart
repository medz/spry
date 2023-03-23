abstract class SessionAdapter {
  const SessionAdapter({required this.expiration});

  /// The [Duration] of the session cookie expiration.
  ///
  /// Default is 20 minutes.
  final Duration expiration;

  /// Returns a session value.
  Future<String?> get(String identifier, String key);

  /// Sets a session value.
  Future<void> set(String identifier, String key, String value);

  /// Returns `true` if the session contains a value for the given [key].
  Future<bool> has(String identifier, String key);

  /// Removes a session value.
  Future<void> remove(String identifier, String key);

  /// Destroys the session.
  Future<void> destroy(String identifier);

  /// Can a session be expired
  Future<bool> can(String identifier);

  /// renew the session
  Future<void> renew(String identifier);

  /// Returns the session expires at.
  Future<DateTime?> expiresAt(String identifier);
}
