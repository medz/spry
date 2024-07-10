import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:spry/spry.dart';

import '_cookies_impl.dart';
import '_internal.dart';
import 'cookies.dart';

/// Wrap a handle closure with cookies.
FutureOr<Response> Function(Event) cookieWith<T>(
  FutureOr<T> Function(Event event) closure, {
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
  final handler = switch (closure) {
    next => null,
    _ => ClosureHandler(closure),
  };

  return (event) async {
    event.locals.set(kCookiesInstance, CookiesImpl(event, hmac));

    final response = await switch (handler) {
      Handler(handle: final handle) => handle(event),
      _ => next(event),
    };
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

/// Creates a cookie support handler closure.
FutureOr<Response> Function(Event) cookie({
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
  return cookieWith(
    next,
    secret: secret,
    algorithm: algorithm,
    autoSecureSet: autoSecureSet,
    expires: expires,
    maxAge: maxAge,
    domain: domain,
    path: path,
    secure: secure,
    httpOnly: httpOnly,
    sameSite: sameSite,
    partitioned: partitioned,
  );
}
