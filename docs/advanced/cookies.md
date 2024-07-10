---
title: Advanced → Cookies
---

# Cookies

[![Pub Version](https://img.shields.io/pub/v/spry_cookie.svg)](https://pub.dev/packages/spry_cookie)

An HTTP cookie is a small piece of data stored by the user's browser. Cookies were designed to be a reliable mechanism for websites to remember stateful information. When the user visits the website again, the cookie is automatically sent with the request.

## Integration

Spry is more focused on routing and APIs servers and does not have built-in support for Cookies.

Install Spry cookies support package (`spry_cookie`):

```bash
dart pub add spry_cookie
```

Or, update your `pubspec.yaml` file:

```dart
dependencies:
    spry_cookie: <latest | ^{version}>
```

## Usege

Spry Cookies supports global and single handler mode.

### Global Support Cookies <Badge type="tip" text="Recommended" />

```dart
import 'package:spry_cookie/spry_cookie.dart';

app.use(cookie());
```

### Only single handler

Wrap a closure handler with `cookieWith`:

```dart
import 'package:spry_cookie/spry_cookie.dart';

app.get('/user', cookieWith((event) {
    // ...
}));
```

## Sign/Unsign cookies

Spray Cookie supports signed and unsigned cookies. You only need to configure the security key and hash algorithm:

```dart
app.use(cookie(
  secret: "Your cookie sign secret",
));
```

By default, the `SHA-256` hash algorithm is used. If you want to customize it, please set `algorithm`:

```dart
import 'package:crypto/crypto.dart';

app.use(cookie(
  secret: "Your cookie sign secret",
  algorithm: md5, // Set algorithm to MD5
));
```

## Automatic `secure` settings

使用 `autoSecureSet` 选项，当 Handler 中未设置 `secure` 时候，会判断当前请求是否是 `https` 自动设置：

```dart
app.use(cookie(
  autoSecureSet: true
));
```

## Cookie options

### `domain`

Specifies the value for the [Domain Set-Cookie attribute](https://datatracker.ietf.org/doc/html/rfc6265#section-5.2.3). By default, no domain is set, and most clients will consider the cookie to apply to only the current domain.

### `expires`

Specifies the `DateTime` to be the value for the [Expires Set-Cookie attribute](https://datatracker.ietf.org/doc/html/rfc6265#section-5.2.1). By default, no expiration is set, and most clients will consider this a "non-persistent cookie" and will delete it on a condition like exiting a web browser application.

::: tip

the [cookie storage model specification](https://datatracker.ietf.org/doc/html/rfc6265#section-5.3) states that if both `expires` and `maxAge` are set, then `maxAge` takes precedence, but it is possible not all clients by obey this, so if both are set, they should point to the same date and time.

:::

### `httpOnly`

Specifies the boolean value for the [HttpOnly Set-Cookie attribute](https://datatracker.ietf.org/doc/html/rfc6265#section-5.2.6). When truthy, the `HttpOnly` attribute is set, otherwise it is not. By default, the `HttpOnly` attribute is not set.

### `maxAge`

Specifies the `int` (in seconds) to be the value for the [Max-Age Set-Cookie attribute](https://datatracker.ietf.org/doc/html/rfc6265#section-5.2.2). The given number will be converted to an integer by rounding down. By default, no maximum age is set.

### `partitioned`

Specifies the `bool?` value for the [Partitioned Set-Cookie attribute](https://datatracker.ietf.org/doc/html/draft-cutler-httpbis-partitioned-cookies#section-2.1). When truthy, the `Partitioned` attribute is set, otherwise it is not. By default, the `Partitioned` attribute is not set.

### `path`

Specifies the value for the [Path Set-Cookie attribute](https://datatracker.ietf.org/doc/html/rfc6265#section-5.2.4). By default, the path is considered the ["default path"](https://datatracker.ietf.org/doc/html/rfc6265#section-5.1.4).

### `secure`

Specifies the boolean value for the [Secure Set-Cookie attribute](https://datatracker.ietf.org/doc/html/rfc6265#section-5.2.5). When truthy, the `Secure` attribute is set, otherwise it is not. By default, the `Secure` attribute is not set.

### `sameSite`

Specifies the `SameSite` enum to be the value for the [SameSite Set-Cookie attribute](https://datatracker.ietf.org/doc/html/draft-ietf-httpbis-rfc6265bis-09#section-5.4.7).

* `SameSite.lax`: will set the `SameSite` attribute to `Lax` for lax same site enforcement.
* `SameSite.none`: will set the `SameSite` attribute to `None` for an explicit cross-site cookie.
* `SameSite.strict`: will set the `SameSite` attribute to `Strict` for strict same site enforcement.

## Managing cookies

We extend the `Event` object to add a `cookies` object to manage Cookies:

```dart
app.use((event) {
    print(event.cookie.get("user_id"));
});
```

### `event.cookies.get`

Gets a Request/Response cookie value.

### `event.cookies.getAll`

Gets all Request/Response cookies list.

### `event.cookies.set`

Sets a new cookie.

### `event.cookies.delete`

Deletes a cookie.

### `event.cookies.serialize`

Serialize a cookie.
