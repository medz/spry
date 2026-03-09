---
title: Deploy → Dart VM
description: Use the Dart target when you want the simplest self-hosted path for a Spry project.
---

# Dart VM

Use `BuildTarget.dart` when:

- you want the simplest local and self-hosted path
- you are deploying into a Dart-native environment
- you do not need a JavaScript-hosted target

## Example config

<<< ../../../example/spry.config.dart

## Local flow

```bash
dart run spry serve
dart run spry build
```

## Why pick Dart

- lowest conceptual overhead
- no JavaScript runtime dependency
- easiest path when your ops environment is already Dart-friendly

If you are starting from zero and not targeting a JS-hosted platform, this is usually the default choice.
