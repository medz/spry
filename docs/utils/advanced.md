---
title: Utils → Advanced
---

# Advanced

Not commonly used or advanced utilities

## `setClientAddress`

Sets a client address in request event.

> **NOTE**: This `setClientAddress` is provided to adapter developers.

```dart
setClientAddress(event, '127.0.0.1:64783');
```

## `createError`

Creates a new Spry error.

```dart
createError('this is error');
```

## `createEvent(Spry, Request)`

Creates a new Spry event instance.

```dart
final event = createEvent(app, request);
```
