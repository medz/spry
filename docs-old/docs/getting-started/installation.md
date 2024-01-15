---
title: Installation
---

# Installation

[[toc]]

::: info Prerequisites
[Dart SDK `>=2.18.6 <3.0.0`](https://dart.dev/get-dart)
:::

## Add to your project

This will add a like this to your project `pubspec.yaml` (and run an implicit `dart pub get`):

```yaml
dependencies:
  spry: latest
```

Or install it yourself as a normal [pub package](https://pub.dev/packages/spry):

```bash
dart pub add spry
```

## You project entry file

Create a file called `main.dart` or edit your existing one.

```dart
import 'package:spry/spry.dart';

final spry = Spry();

void handler(Context context) {
  context.response.text('Hello World!');
}
```
