import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:spry/spry.dart';

import '_internal.dart';
import 'cookies.dart';

final class CookiesImpl implements Cookies {
  const CookiesImpl(this.event, [this.hmac]);

  final Event event;
  final Hmac? hmac;

  @override
  String? get(String name, {String Function(String value)? decode}) {
    final normalizedName = name.toLowerCase();
    for (final cookie in event.responseCookies) {
      if (cookie.name.toLowerCase() == normalizedName) {
        return decodeSignedValue(cookie.value);
      }
    }

    final requestCookieValue = event.requestCookies[normalizedName];
    if (requestCookieValue != null) {
      return decodeSignedValue(requestCookieValue);
    }

    return null;
  }

  @override
  Iterable<(String, String)> getAll() sync* {
    for (final cookie in event.requestCookies.entries) {
      final value = decodeSignedValue(cookie.value);
      if (value == null) continue;

      yield (cookie.key, value);
    }

    for (final cookie in event.responseCookies) {
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
    event.responseCookies.add(SetCookie(
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
    event.responseCookies
        .removeWhere((e) => e.name.toLowerCase() == name.toLowerCase());

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
    return SetCookie(
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
