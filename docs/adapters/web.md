---
title: Adapter → Web
description: Run your Spry apps in edge runtimes with Web API compatibility.
---

# Web

{{ $frontmatter.description }}

---

In order to run Spry apps in web compatible edge runtimes supporting
[fetch API](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API)
with [`Request`](https://developer.mozilla.org/en-US/docs/Web/API/Request)
and [`Response`](https://developer.mozilla.org/en-US/docs/Web/API/Response),
use `toWebHandler` adapter to convert Spry app into a fetch-like function.

## Usage

First, create an Spry app:

::: code-group
```dart [app.dart]
import 'package:spry/spry.dart';

final app = createSpry()
    ..use((event) => 'Hello world!');
```
:::

Create web entry:

::: code-group
```dart [web.dart]
import 'package:spry/web.dart';
import 'app.dart';

final handler = toWebHandler(app);
```
:::

## Local testing

You can test adapter using any compatible JavaScript runtime by passing a Request object.

::: code-group
```dart [web_test.dart]
import 'package:web/web.dart';
import 'web.dart';

main() async {
    final request = Request('http://localhost/'.toJS);
    final response = await handler(request);

    print(await response.text().toDart); // Hello world!
}
```
:::

Compile to JavaScript file:

```bash
dart compile js web_test.dart -o web_test.js
```

Run the `web_test.js`:

::: code-group
```bash [Bun]
bun ./web_test.js
```

```bash [Node.js]
node ./web_test.js
```

```html [Browser]
<script src="web_test.js"></script>
```
:::

## Advanced Utils

### `createWebEvent`

Create a new event for web.

```dart
final event = createWebEvent(app, request);
```

### `toWebResponse`

Spry response to web response object.

```dart
final response = toWebResponse(spryResponse);
```

### `toWebHeaders`

Spry headers to web headers object.

```dart
final spryHeaders = Headers({"context-type": "application/json"});
final headers = toWebHeaders(spryHeaders);
```

### `toSpryHeaders`

Creates a new Spry headers for web headers object.

```dart
final headers = toSpryHeaders(webHeaders);
```
