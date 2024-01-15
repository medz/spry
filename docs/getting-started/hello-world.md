---
title: Getting Started → Hello world
---

# Hello world

```dart
import 'package:spry/spry.dart';

final app = Application.create(port: 3000);

main() {
  app.get("/", (request) => "Hello, Spry!");

  app.listen();
}
```

The application creates a server and listens for requests on port `3000`, responding to the `/` path for `GET` requests. For all other requests, it will return a `404` response.
