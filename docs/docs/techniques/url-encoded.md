---
title: URL Encoded
---

# URL Encoded

[[toc]]

## Import URL Encoded

To use URL Encoded, you need to import the `spry` package:

```dart
import 'package:spry/urlencoded.dart';
```

## Read URL encoded from request

You can read URL encoded from the request:

```dart
void handler(Context context) async {
  final urlencoded = await context.request.urlencoded();
}
```

## Write URL encoded to response

You can write URL encoded to the response:

```dart
void handler(Context context) {
  context.response.urlencoded({'key': 'value'});
}
```
