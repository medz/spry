---
title: Getting Started → Hello world
---

# Hello world

```dart
import 'package:spry/spry.dart';

final app = Application.late();

main() async {
  app.get("hello", (request) => "Hello, Spry!");

  await app.run(port: 3000);
}
```

The application creates a server and listens for requests on port `3000`, responding to the `/` path for `GET` requests. For all other requests, it will return a `404` response.
