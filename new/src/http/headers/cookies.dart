import 'dart:io';

import '../../utilities/uri.dart';

typedef CookieCodec = String Function(String value);

class Cookies {
  final _CookiesStorage _storage;

  const Cookies._(this._storage);
  factory Cookies(Iterable<Cookie> request, List<Cookie> response) =>
      Cookies._(_CookiesStorage(request, response));

  /// Gets all cookies that were previously set with `cookies.set`, or from
  /// the request headers.
  Iterable<(String, String)> getAll(
      {CookieCodec decode = URI.decodeComponent}) sync* {
    yield* _storage.response.toRecords(decode);
    yield* _storage.request.toRecords(decode);
  }

  /// Gets a cookie that was previously set with `cookies.set`, or from the
  /// request headers.
  String? get(String name, {CookieCodec decode = URI.decodeComponent}) {
    bool test(Cookie cookie) => cookie.name == name;
    final cookie = _storage.response.firstWhereOrNull(test) ??
        _storage.request.firstWhereOrNull(test);

    return decode.tryRun(cookie?.value);
  }

  /// Sets a cookie. This will add a `set-cookie` header to the response.
  void set(String name, String value,
      {DateTime? expires,
      int? maxAge,
      String? domain,
      String? path,
      bool secure = false,
      bool httpOnly = false,
      SameSite? sameSite,
      CookieCodec encode = URI.encodeComponent}) {
    final cookie = Cookie(name, encode.tryRun(value)!)
      ..expires = expires
      ..maxAge = maxAge
      ..domain = domain
      ..path = path
      ..secure = secure
      ..httpOnly = httpOnly
      ..sameSite = sameSite;

    _storage.response.add(cookie);
  }

  /// Deletes a cookie by setting its value to an empty string and setting the
  /// expiry date in the past.
  void delete(String name,
          {String? domain,
          String? path,
          bool secure = false,
          bool httpOnly = false,
          SameSite? sameSite}) =>
      set(name, '',
          expires: DateTime.fromMillisecondsSinceEpoch(0),
          domain: domain,
          path: path,
          secure: secure,
          httpOnly: httpOnly,
          sameSite: sameSite,
          encode: (value) => value);

  /// Serialize a cookie name-value pair into a `Set-Cookie` header string, but
  /// don't apply it to the response.
  String serialize(String name, String value,
          {DateTime? expires,
          int? maxAge,
          String? domain,
          String? path,
          bool secure = false,
          bool httpOnly = false,
          SameSite? sameSite,
          CookieCodec encode = URI.encodeComponent}) =>
      (
        Cookie(name, encode.tryRun(value)!)
          ..expires = expires
          ..maxAge = maxAge
          ..domain = domain
          ..path = path
          ..secure = secure
          ..httpOnly = httpOnly
          ..sameSite = sameSite,
      ).toString();
}

class _CookiesStorage {
  final Iterable<Cookie> request;
  final List<Cookie> response;

  const _CookiesStorage(this.request, this.response);
}

extension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }

    return null;
  }
}

extension on Iterable<Cookie> {
  Iterable<(String, String)> toRecords(CookieCodec codec) =>
      map((cookie) => (cookie.name, codec.tryRun(cookie.value)!));
}

extension on CookieCodec {
  String? tryRun(String? value) {
    if (value == null) return null;

    try {
      return this(value);
    } catch (_) {
      return null;
    }
  }
}
