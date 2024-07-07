enum SameSite { lax, strict, none }

abstract interface class Cookies {
  String? get(String name, {String Function(String value)? decode});

  Iterable<(String, String)> getAll({String Function(String value)? decode});

  void set(
    String name,
    String value, {
    DateTime? expires,
    int? maxAge,
    String? domain,
    String? path,
    bool secure = false,
    bool httpOnly = false,
    SameSite? sameSite,
    String Function(String value)? encode,
  });

  void delete(
    String name, {
    DateTime? expires,
    int? maxAge,
    String? domain,
    String? path,
    bool secure = false,
    bool httpOnly = false,
    SameSite? sameSite,
  });

  String serialize(
    String name,
    String value, {
    DateTime? expires,
    int? maxAge,
    String? domain,
    String? path,
    bool secure = false,
    bool httpOnly = false,
    SameSite? sameSite,
    String Function(String value)? encode,
  });
}
