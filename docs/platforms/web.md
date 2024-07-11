---
title: Platforms → Web
---

# Web

Run your Spry app in edge runtimes with Web API compatibility.

---

In order to run Spry app in web compatible edge runtimes supporting [`fetch` API](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API) with [Request](https://developer.mozilla.org/en-US/docs/Web/API/Request) and [Response](https://developer.mozilla.org/en-US/docs/Web/API/Response), use `WebPlatform` platform to convert Spry app into a fetch-like function.

## Pre dependencies

* [`web`](https://pub.dev/packages/web): Run with `dart pub add web` install the [`web`](https://pub.dev/packages/web) package.

## Usage

First, create app entry:

::: code-group
```dart [app.dart]
import 'package:spry/spry.dart';

final app = () {
    final app = Spry();

    app.use((event) => Response.text('Hello world!'));

    return app
}();
```
:::

Create web entry:

::: code-group
```dart [web.dart]
import 'package:spry/web.dart';
import 'app.dart';

final handler = const WebPlatform().createHandler(app);
```
:::

## Local testing

You can test using any compatible JavaScript runtime by passing a Request object.

::: code-group
```dart [web_test.dart]
import 'package:web/web.dart';
import 'web.dart';

void main() async {
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
bun run web_test.js
```

```bash [Node.js]
node ./web_test.js
```

```html [Browser]
<script src="web_test.js"></script>
```
:::
