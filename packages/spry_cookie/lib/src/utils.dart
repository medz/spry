import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:spry/spry.dart';

import '_cookies_impl.dart';
import '_internal.dart';
import 'cookies.dart';

/// Creates a cookie support handler closure.
Future<Response> Function(Event) cookie({
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
    event.locals.set(kCookiesInstance, CookiesImpl(event, hmac));

    final response = await next(event);
    final cookies = event.responseCookies;
    final builder = response.headers.toBuilder();
    final autoSecure = switch (autoSecureSet) {
      true => event.uri.isScheme('https') || event.uri.isScheme('wss'),
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

      builder.add('set-cookie', cookie.toString());
    }

    cookies.clear();

    return response.copyWith(headers: builder.toHeaders());
  };
}
