import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http_parser/http_parser.dart';

import 'spry.dart';

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

class _SetCookie {
  _SetCookie(
    this.name,
    this.value, {
    this.expires,
    this.maxAge,
    this.domain,
    this.path,
    this.secure,
    this.httpOnly,
    this.sameSite,
    this.partitioned,
  });

  final String name;
  final String value;
  DateTime? expires;
  int? maxAge;
  String? domain;
  String? path;
  bool? secure;
  bool? httpOnly;
  SameSite? sameSite;
  bool? partitioned;

  @override
  String toString() {
    final buffer = StringBuffer()
      ..write(name)
      ..write('=')
      ..write(value);

    if (expires != null) {
      buffer
        ..write('; Expires=')
        ..write(formatHttpDate(expires!));
    }

    if (maxAge != null) {
      buffer
        ..write('; Max-Age=')
        ..write(maxAge);
    }

    if (domain != null) {
      buffer
        ..write('; Domain=')
        ..write(domain);
    }

    if (path != null) {
      buffer
        ..write('; Path=')
        ..write(path);
    }

    if (secure == true) buffer.write('; Secure');
    if (httpOnly == true) buffer.write('; HttpOnly');
    if (partitioned == true) buffer.write('; Partitioned');
    if (sameSite != null) {
      buffer.write('; SameSite=');
      buffer.write(switch (sameSite!) {
        SameSite.lax => 'Lax',
        SameSite.strict => 'Strict',
        SameSite.none => 'None',
      });
    }

    return buffer.toString();
  }
}

final class _CookiesImpl extends Iterable<_SetCookie> implements Cookies {
  _CookiesImpl(this.cookies, this.hmac);

  final Map<String, String> cookies;
  final Hmac? hmac;
  final setCookies = <_SetCookie>[];

  @override
  Iterator<_SetCookie> get iterator => setCookies.iterator;

  void clear() => setCookies.clear();

  @override
  String? get(String name) {
    final normalizedName = name.toLowerCase();
    for (final cookie in cookies.entries) {
      if (cookie.key.toLowerCase() == normalizedName) {
        return decodeSignedValue(cookie.value);
      }
    }

    for (final cookie in this) {
      if (cookie.name.toLowerCase() == normalizedName) {
        return decodeSignedValue(cookie.value);
      }
    }

    return null;
  }

  @override
  Iterable<(String, String)> getAll() sync* {
    for (final cookie in cookies.entries) {
      final value = decodeSignedValue(cookie.value);
      if (value == null) continue;

      yield (cookie.key, value);
    }

    for (final cookie in this) {
      final value = decodeSignedValue(cookie.value);
      if (value == null) continue;

      yield (cookie.name, value);
    }
  }

  @override
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
  }) {
    setCookies.add(_SetCookie(
      name,
      encodeSignedValue(value),
      expires: expires,
      maxAge: maxAge,
      domain: domain,
      path: path,
      secure: secure,
      httpOnly: httpOnly,
      sameSite: sameSite,
      partitioned: partitioned,
    ));
  }

  @override
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
  }) {
    setCookies.removeWhere((e) => e.name.toLowerCase() == name.toLowerCase());

    set(name, '',
        expires: expires ?? DateTime.now(),
        maxAge: maxAge,
        domain: domain,
        path: path,
        secure: secure,
        httpOnly: httpOnly,
        sameSite: sameSite,
        partitioned: partitioned);
  }

  @override
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
    bool signed = true,
    bool? partitioned,
  }) {
    return _SetCookie(
      name,
      signed ? encodeSignedValue(value) : value,
      expires: expires,
      maxAge: maxAge,
      domain: domain,
      path: path,
      secure: secure,
      httpOnly: httpOnly,
      sameSite: sameSite,
      partitioned: partitioned,
    ).toString();
  }

  String encodeSignedValue(String value) {
    if (value.isEmpty) return '';
    if (hmac == null) return Uri.encodeComponent(value);

    final bytes = utf8.encode(value);
    final hex = base64Url.encode(hmac!.convert(bytes).bytes);
    final encoded = base64Url.encode(bytes);

    return Uri.encodeComponent('$encoded.$hex'.replaceAll('=', ''));
  }

  String? decodeSignedValue(String signed) {
    if (signed.isEmpty) return null;
    if (hmac == null) return Uri.decodeComponent(signed);

    final parts = signed.split('.');
    if (parts.length < 2) return null;

    final [...encodedParts, sign] = parts;
    final bytes = base64Url.decode(Uri.decodeComponent(encodedParts.join('.')));
    final hex =
        base64Url.encode(hmac!.convert(bytes).bytes).replaceAll('=', '');

    if (hex == Uri.decodeComponent(sign)) {
      return utf8.decode(bytes);
    }

    return null;
  }
}

_CookiesImpl _createCookies(Event event, Hmac? hmac) {
  final cookies = useHeaders(event)
      .getAll('cookie')
      .map((e) => e.split(';'))
      .expand((e) => e)
      .map((e) {
    final [name, ...values] = e.split('=');
    return MapEntry(name.toLowerCase().trim(), values.join('=').trim());
  });

  return _CookiesImpl(Map.fromEntries(cookies), hmac);
}

const _kCookies = #spry.event.cookies;

/// Enable cookie suppory.
///
/// The [enableCookie] create a Spry handler.
///
/// ```dart
/// app.use(enableCookie());
/// ```
Handler<Response> enableCookie({
  String? secret,
  Hash algorithm = sha256,
  bool autoSecureSet = true,
  DateTime? expires,
  int? maxAge,
  String? domain,
  String? path,
  bool? secure,
  bool? httpOnly,
  SameSite? sameSite,
  bool? partitioned,
}) {
  final hmac = switch (secret) {
    String secret => Hmac(algorithm, utf8.encode(secret)),
    _ => null
  };

  return (event) async {
    final cookies = _createCookies(event, hmac);
    event.set(_kCookies, cookies);

    final response = await next(event);
    final hasSchema = useRequestURI(event).isScheme;
    final autoSecure = switch (autoSecureSet) {
      true => hasSchema('https') || hasSchema('wss'),
      _ => false,
    };

    for (final cookie in cookies) {
      cookie
        ..expires = cookie.expires ?? expires
        ..maxAge = cookie.maxAge ?? maxAge
        ..domain = cookie.domain ?? domain
        ..path = cookie.path ?? path
        ..secure = cookie.secure ?? secure ?? autoSecure
        ..httpOnly = cookie.httpOnly ?? httpOnly
        ..sameSite = cookie.sameSite ?? sameSite
        ..partitioned = cookie.partitioned ?? partitioned;

      response.headers.add('set-cookie', cookie.toString());
    }

    cookies.clear();

    return response;
  };
}

/// Returns a [Cookies] instance for the [event].
Cookies useCookies(Event event) {
  return switch (event.get<Cookies>(_kCookies)) {
    Cookies cookies => cookies,
    _ => throw createError(
        'Cookies are not enabled.'
        'Please enable using `app.use(enableCookie(...))`',
      ),
  };
}
