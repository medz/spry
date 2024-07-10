---
title: Platforms → IO (dart:io)
---

# IO <Badge type="tip" text="dart:io" />

Natively run Spry app with `dart:io` HTTP server.

---

To listen to `HttpServer` and enable Spry app, convert Spry app to `dart:io` HTTP server listener using `IOPlatform` platform.

## Usage

First, create an Spry app:

::: code-group
```dart [app.dart]
import 'package:spry/spry.dart';

final Spry app = () {
  final app = Spry();
  app.use((event) => 'hello world!');

  return app;
}();
```
:::

Create HTTP server entry:

::: code-group
```dart [server.dart]
import 'package:spry/spry.dart';

void main() async {
  final server = await HttpServer.bind('127.0.0.1', 3000);
  final handler = const IOPlatform().createHandler(app);

  server.listen(handler);

  print('🚀 HTTP server listen on http://127.0.0.1:3000');
}
```
:::

Now, you can run you Spry app natively with `dart:io`:

```bash
dart run server.dart
```

## Compile to executable program

The IO platform allows you to compile to binary executable programs using the `dart compile exe` command:

```bash
dart compile exe server.dart -o server
```

Start the server:

```bash
./server
# console: 🚀 HTTP server listen on http://127.0.0.1:3000
```
