---
title: Configuration
---

# Configuration

[[toc]]

## Encoding

Spry application uses `utf-8` encoding by default for all requests and responses.

You can change the default encoding by setting the `encoding` property on the `Spry` instance:

```dart
final spry = Spry(
  encoding: latin1,
);
```

## Powered by

Spry application adds a `X-Powered-By` header to all responses by default.

You can change the default value by setting the `poweredBy` property on the `Spry` instance:

```dart
final spry = Spry(
  poweredBy: 'Spry',
);
```

If you want to disable the `X-Powered-By` header, set the `poweredBy` property to `null`:

```dart
final spry = Spry(
  poweredBy: null,
);
```
