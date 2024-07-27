---
title: Adapter → Bun
description: Run your Spry apps with Bun
---

# Web

{{ $frontmatter.description }}

---

In order to run Spry apps in [Bun](https://bun.sh), use the [Web Adapter](/adapters/web).

## Usage

First, create an Spry app:

::: code-group
```dart [app.dart]
import 'package:spry/spry.dart';

final app = createSpry()
    ..use((event) => 'Hello world!');
```
:::

Create Bun server entry:

::: code-group
```dart [serve.dart]
import 'package:spry/bun.dart';
import 'app.dart';

main() async {
    final serve = toBunServe(app)..port = 3000;
    Bun.serve(serve);
}
```
:::

Compile to JavaScript file:

```bash
dart compile js server.dart -o server.js
```

Run the `server.js`:

```bash
bun ./server.js
```

## Other

The Bun adapter defines the most basic Bun types to satisfy basic Bun HTTP server requirements using JS interop.

If you need more advanced customization, please extend it yourself.
