/// [Set-Cookie#samesitesamesite-value](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie#samesitesamesite-value)
enum SameSite { lax, strict, none }

/// Spry cookies.
abstract interface class Cookies {
  /// Gets a Request/Response cookie value.
  String? get(String name);

  /// Gets all Request/Response cookies.
  Iterable<(String, String)> getAll();

  /// Sets a new cookie.
  void set(
    String name,
    String value, {
    DateTime? expires,
    int? maxAge,
    String? domain,
    String? path,
    bool? secure,
    bool? httpOnly,
    SameSite? sameSite,
    bool? partitioned,
  });

  /// Deletes a cookie.
  void delete(
    String name, {
    DateTime? expires,
    int? maxAge,
    String? domain,
    String? path,
    bool? secure,
    bool? httpOnly,
    SameSite? sameSite,
    bool? partitioned,
  });

  /// Serialize a cookie.
  String serialize(
    String name,
    String value, {
    DateTime? expires,
    int? maxAge,
    String? domain,
    String? path,
    bool? secure,
    bool? httpOnly,
    SameSite? sameSite,
    bool? partitioned,
    bool signed,
  });
}
