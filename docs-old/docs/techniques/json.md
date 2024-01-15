---
title: JSON
---

# JSON

[[toc]]

## Import JSON

To use JSON, you need to import the `spry` package:

```dart
import 'package:spry/json.dart';
```

## Read JSON from request

You can read JSON from the request:

```dart
void handler(Context context) async {
  final json = await context.request.json();
}
```

## Write JSON to response

You can write JSON to the response:

```dart
void handler(Context context) {
  context.response.json({'key': 'value'});
}
```
