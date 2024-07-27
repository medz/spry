---
title: Advanced → Cookies
---

# Cookies

An HTTP cookie is a small piece of data stored by the user's browser. Cookies were designed to be a reliable mechanism for websites to remember stateful information. When the user visits the website again, the cookie is automatically sent with the request.

## Enable cookie

To use cookies in Spry, you must register an event handler using `enableCookie`:

```dart
import 'package:spry/cookie.dart';

app.use(enableCookie());
```

You can also activate according to the routing group:

```dart
import 'package:spry/cookie.dart';

final web = app.grouped(uses: [enableCookie()]);

web.get('/user', (event) => ...);
```

## Cookie signature

Sign and unsign cookies.

```dart
app.use(enableCookie(secret: '123456'));
```

## Utils

Gets the `Cookies` for event handler using `useCookies`:

```dart
import 'package:spry/cookie.dart';

app.use(enableCookie());
app.use((event) {
    final cookies = useCookies(event);

    cookies.set('hello', 'spry');
});
```
