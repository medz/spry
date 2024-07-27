---
title: Adapter → `dart:io`
description: Natively run Spry servers with `dart:io`.
---

# IO (`dart:io`)

{{ $frontmatter.description }}

---

In order to start Spry apps in `dart:io` HTTP server, use `toIOHandler` adapter to convert h3 app into a dart HTTP server request listener.

## Usage

First, create an Spry app:

::: code-group
```dart [app.dart]
import 'package:spry/spry.dart';

final app = createSpry()
    ..use((event) => 'Hello world!');
```
:::

Create Dart HTTP server entry:

::: code-group
```dart [server.dart]
import 'dart:io';
import 'package:spry/io.dart';
import 'app.dart';

main() async {
    final handler = toIOHandler(app);
    final server = await HttpServer.bind('127.0.0.1', 3000);

    server.listen(handler);
}
```
:::

Now, you can run you Spry app natively with IO:

```bash
dart run server.dart
```
