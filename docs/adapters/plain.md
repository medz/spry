---
title: Adapter → Plain
description: Run Spry app into any unknown runtime.
---

# Web

{{ $frontmatter.description }}

---

Using plain adapter you can have an object input/output interface.

::: tip
This can be also be particularly useful for testing your app or running inside lambda-like environments.
:::

## Usage

First, create an Spry app:

::: code-group
```dart [app.dart]
import 'package:spry/spry.dart';

final app = createSpry()
    ..use((event) => 'Hello world!');
```
:::

Create plain entry:

::: code-group
```dart [plain.dart]
import 'package:spry/plain.dart';
import 'app.dart';

final handler = toPlainHandler(app);
```
:::

## Local testing

You can test platform using any runtime:

```dart
import 'package:spry/spry.dart';
import 'package:test/test.dart';
import 'plain.dart';

void main() {
  test('Basic request', () async {
    final request = Request(
        method: 'get',
        uri: Uri(path: '/'),
        headers: Headers(),
    );
    final response = await handler(request);

    expect(response.status, 200);
    expect(response.headers.get('content-type'), contains('text/plain'));
    expect(await response.text(), contains('hello world'));
  });
}
```

The response example JSON (This is not a real return, but just a visual demonstration of data):

```json
{
  status: 200,
  statusText: "OK",
  headers: {
    "content-type": "text/plain; charset=utf8"
  },
  body: "hello world!"
}
```
