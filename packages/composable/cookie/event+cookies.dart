// // ignore_for_file: file_names

// import 'package:spry/spry.dart';

// import 'cookies.dart';
// import '_event_internal_utils.dart';

// extension EventCookies on Event {
//   Cookies get cookies {
//     return locals.getOrSet<Cookies>(Cookies, () => _CookiesImpl(this));
//   }
// }

// final class _CookiesImpl implements Cookies {
//   static const defaultEncode = Uri.encodeComponent;
//   static const defaultDecode = Uri.decodeComponent;

//   const _CookiesImpl(this.event);

//   final Event event;

//   @override
//   String? get(String name, {String Function(String value)? decode}) {
//     final normalizedName = name.toLowerCase();
//     for (final cookie in event.responseCookies) {
//       if (cookie.name.toLowerCase() == normalizedName) {
//         return (decode ?? defaultDecode).call(cookie.value);
//       }
//     }

//     final requestCookieValue = event.requestCookies[normalizedName];
//     if (requestCookieValue != null) {
//       return (decode ?? defaultDecode).call(requestCookieValue);
//     }

//     return null;
//   }

//   @override
//   Iterable<(String, String)> getAll(
//       {String Function(String value)? decode}) sync* {
//     final inner = decode ?? defaultDecode;

//     yield* event.requestCookies.entries.map((e) => (e.key, inner(e.value)));
//     yield* event.responseCookies.map((e) => (e.name, inner(e.value)));
//   }

//   @override
//   void set(String name, String value,
//       {DateTime? expires,
//       int? maxAge,
//       String? domain,
//       String? path,
//       bool secure = false,
//       bool httpOnly = false,
//       SameSite? sameSite,
//       String Function(String value)? encode}) {
//     event.responseCookies.add(SetCookie(
//       name,
//       (encode ?? defaultEncode).call(value),
//       expires: expires,
//       maxAge: maxAge,
//       domain: domain,
//       path: path,
//       secure: secure,
//       httpOnly: httpOnly,
//       sameSite: sameSite,
//     ));
//   }

//   @override
//   void delete(String name,
//       {DateTime? expires,
//       int? maxAge,
//       String? domain,
//       String? path,
//       bool secure = false,
//       bool httpOnly = false,
//       SameSite? sameSite}) {
//     event.responseCookies
//         .removeWhere((e) => e.name.toLowerCase() == name.toLowerCase());

//     set(name, '',
//         expires: expires ?? DateTime.now(),
//         maxAge: maxAge,
//         domain: domain,
//         path: path,
//         secure: secure,
//         httpOnly: httpOnly,
//         sameSite: sameSite);
//   }

//   @override
//   String serialize(String name, String value,
//       {DateTime? expires,
//       int? maxAge,
//       String? domain,
//       String? path,
//       bool secure = false,
//       bool httpOnly = false,
//       SameSite? sameSite,
//       String Function(String value)? encode}) {
//     return SetCookie(
//       name,
//       (encode ?? defaultEncode).call(value),
//       expires: expires,
//       maxAge: maxAge,
//       domain: domain,
//       path: path,
//       secure: secure,
//       httpOnly: httpOnly,
//       sameSite: sameSite,
//     ).toString();
//   }
// }
