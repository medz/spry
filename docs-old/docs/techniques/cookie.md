---
title: Cookie
---

# Cookie

[[toc]]

## Read cookies from request

You can read cookie from the request:

```dart
void handler(Context context) {
  final cookies = context.request.cookies;
}
```

## Write cookies to response

You can write cookie to the response:

```dart
context.response.cookies.add(Cookie('key', 'value'));
```

## Example

::: code-group

```dart [Server]
final spry = Spry();

void handler(Context context) {
  final cookie = context.request.cookies.firstWhere(
    (cookie) => cookie.name == 'key',
    orElse: () => Cookie.fromSetCookieValue('0'),
  );

  print(cookie.value);

  final count = int.parse(cookie.value) + 1;

  context.response.cookies.add(Cookie('key', count.toString()));
}

void main() => spry.listen(handler, port: 3000);
```

```sh [cURL]
curl -i http://localhost:3000
curl -i http://localhost:3000
```

```sh [Output]
HTTP/1.1 200 OK - 0
HTTP/1.1 200 OK - 1
```

:::
