// import 'package:http_parser/http_parser.dart';
// import 'package:spry/spry.dart';

// import 'cookies.dart';

// extension EventInternalUtils on Event {
//   Map<String, String> get requestCookies {
//     return locals.getOrSet<Map<String, String>>(
//       #spry.event.request.cookies,
//       () => request.headers.cookies,
//     );
//   }

//   List<SetCookie> get responseCookies {
//     return locals.getOrSet<List<SetCookie>>(
//       #spry.event.response.cookies,
//       () => <SetCookie>[],
//     );
//   }
// }

// class SetCookie {
//   const SetCookie(
//     this.name,
//     this.value, {
//     this.expires,
//     this.maxAge,
//     this.domain,
//     this.path,
//     this.secure = false,
//     this.httpOnly = false,
//     this.sameSite,
//   });

//   final String name;
//   final String value;
//   final DateTime? expires;
//   final int? maxAge;
//   final String? domain;
//   final String? path;
//   final bool secure;
//   final bool httpOnly;
//   final SameSite? sameSite;

//   @override
//   toString() {
//     final buffer = StringBuffer()
//       ..write(name)
//       ..write('=')
//       ..write(value);

//     if (expires != null) {
//       buffer
//         ..write('; Expires=')
//         ..write(formatHttpDate(expires!));
//     }

//     if (maxAge != null) {
//       buffer
//         ..write('; MaxAge=')
//         ..write(maxAge);
//     }

//     if (domain != null) {
//       buffer
//         ..write('Domain=')
//         ..write(domain);
//     }

//     if (path != null) {
//       buffer
//         ..write('; Path=')
//         ..write(path);
//     }

//     if (secure) buffer.write('; Secure');
//     if (httpOnly) buffer.write('; HttpOnly');
//     if (sameSite != null) {
//       buffer.write('; SameSite=');
//       buffer.write(switch (sameSite!) {
//         SameSite.lax => 'Lax',
//         SameSite.strict => 'Strict',
//         SameSite.none => 'None',
//       });
//     }

//     return buffer.toString();
//   }
// }

// extension on Headers {
//   Map<String, String> get cookies {
//     final entries =
//         getAll('cookie').map((e) => e.split(';')).expand((e) => e).map((e) {
//       final [name, ...values] = e.split('=');
//       return MapEntry(name.toLowerCase().trim(), values.join('=').trim());
//     });

//     return Map.fromEntries(entries);
//   }
// }
