import 'package:http_parser/http_parser.dart';
import 'package:spry/spry.dart';

import 'cookies.dart';

const kCookiesInstance = #spry.cookies;
const kRequestCookies = #spry.event.request.cookies;
const kResponseCookies = #spry.event.response.cookies;

extension EventInternalUtils on Event {
  Map<String, String> get requestCookies {
    return locals.getOrSet<Map<String, String>>(
      kRequestCookies,
      () => request.headers.cookies,
    );
  }

  List<SetCookie> get responseCookies {
    return locals.getOrSet<List<SetCookie>>(
      kResponseCookies,
      () => <SetCookie>[],
    );
  }
}

class SetCookie {
  SetCookie(
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

extension on Headers {
  Map<String, String> get cookies {
    final entries =
        getAll('cookie').map((e) => e.split(';')).expand((e) => e).map((e) {
      final [name, ...values] = e.split('=');
      return MapEntry(name.toLowerCase().trim(), values.join('=').trim());
    });

    return Map.fromEntries(entries);
  }
}
