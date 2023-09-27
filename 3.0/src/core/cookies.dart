import 'dart:io';

import 'package:stdweb/stdweb.dart';

import '../_internal/iterable.dart';

typedef CookieCodec = String Function(String value);

class CookieEntry {
  final String name;
  final String value;

  const CookieEntry(this.name, this.value);
}

class Cookies {
  final Iterable<Cookie> _requestCookies;
  final List<Cookie> _responseCookies;

  const Cookies(Iterable<Cookie> requestCookies, List<Cookie> responseCookies)
      : _requestCookies = requestCookies,
        _responseCookies = responseCookies;

  /// Gets a cookie that was previously set with `cookies.set`, or from the request headers.
  ///
  /// - [name] - The name of the cookie to get.
  /// - [decode] - A function to decode the cookie value, defaults to [decodeURIComponent].
  String? get(String name, {CookieCodec decode = decodeURIComponent}) {
    bool test(Cookie cookie) => cookie.name == name;
    final cookie = _responseCookies.firstWhereOrNull(test) ??
        _withoutResponseCookies.firstWhereOrNull(test);

    return cookie == null ? null : _codecCaller(cookie.value, decode);
  }

  /// Gets all cookies that were previously set with `cookies.set`, or from the request headers.
  ///
  /// - [decode] - A function to decode the cookie value, defaults to [decodeURIComponent].
  Iterable<CookieEntry> getAll(
      {CookieCodec decode = decodeURIComponent}) sync* {
    yield* _toCookieEntries(_responseCookies, decode);
    yield* _toCookieEntries(_withoutResponseCookies, decode);
  }

  /// Sets a cookie. This will add a `set-cookie` header to the response.
  ///
  /// - [name] - The name of the cookie to set.
  /// - [value] - The value of the cookie to set.
  /// - [encode] - A function to encode the cookie value, defaults to [encodeURIComponent].
  ///
  /// **Note**: More options see [Cookie] properties.
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
    CookieCodec encode = encodeURIComponent,
  }) {
    _responseCookies.add(
      Cookie(name, _codecCaller(value, encode))
        ..expires = expires
        ..maxAge = maxAge
        ..domain = domain
        ..path = path
        ..secure = secure
        ..httpOnly = httpOnly
        ..sameSite = sameSite,
    );
  }

  /// Deletes a cookie by setting its value to an empty string and setting the expiry date in the past.
  ///
  /// - [name] - The name of the cookie to delete.
  /// **Note**: More options see [Cookie] properties.
  void delete(
    String name, {
    String? domain,
    String? path,
    bool secure = false,
    bool httpOnly = false,
    SameSite? sameSite,
  }) {
    _responseCookies.add(
      Cookie(name, '')
        ..expires = DateTime.fromMillisecondsSinceEpoch(0)
        ..domain = domain
        ..path = path
        ..secure = secure
        ..httpOnly = httpOnly
        ..sameSite = sameSite,
    );
  }

  /// Serialize a cookie name-value pair into a `Set-Cookie` header string, but don't apply it to the response.
  ///
  /// See [set] for more details.
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
    CookieCodec encode = encodeURIComponent,
  }) {
    return (
      Cookie(name, _codecCaller(value, encode))
        ..expires = expires
        ..maxAge = maxAge
        ..domain = domain
        ..path = path
        ..secure = secure
        ..httpOnly = httpOnly
        ..sameSite = sameSite,
    ).toString();
  }

  /// Returns request cookies without response cookies.
  Iterable<Cookie> get _withoutResponseCookies => _requestCookies.where(
        (cookie) => !_responseCookies.any(
          (element) => element.name == cookie.name,
        ),
      );

  /// Converts a Cookie list to CookieEntry list.
  Iterable<CookieEntry> _toCookieEntries(
      Iterable<Cookie> cookies, CookieCodec decode) sync* {
    for (final cookie in _requestCookies) {
      yield CookieEntry(cookie.name, _codecCaller(cookie.value, decode));
    }
  }

  /// Encode or decode a cookie value.
  String _codecCaller(String value, CookieCodec codec) {
    try {
      return codec(value);
    } catch (_) {
      return value;
    }
  }
}
