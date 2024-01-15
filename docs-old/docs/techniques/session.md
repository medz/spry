---
title: Session
---

# Session

[[toc]]

## Overview

Session is a technique that allows you to store data in the user's browser.

Spry is specially designed and encapsulated for Session scenarios, allowing your network applications to have a higher degree of session freedom.

## Import Session

To use Session, you need to import the `spry` package:

```dart
import 'package:spry/session.dart';
```

## Register Session manager

You need to register a Session manager before using Session:

```dart
final spry = Spry();
final sessionManager = SessionManager();

spry.use(sessionManager);
```

> **Note**: The Session manager uses momory session adapter by default. You can also use other session adapters.

## Configuration

When creating a session manager, some default configurations will be used, of course you can customize them:

| Name                  | Type                         | Default                  | Description                  |
| --------------------- | ---------------------------- | ------------------------ | ---------------------------- |
| `adapter`             | `SessionAdapter`             | `MemorySessionAdapter()` | Session adapter              |
| `name`                | `String`                     | `SPRY_SESSION_ID`        | Cookie name                  |
| `domain`              | `String`                     | `null`                   | Cookie domain                |
| `path`                | `String`                     | `null`                   | Cookie path                  |
| `secure`              | `bool`                       | `false`                  | Cookie secure                |
| `httpOnly`            | `bool`                       | `true`                   | Cookie httpOnly              |
| `identifierGenerator` | `SessionIdentifierGenerator` | Built-in generator       | Session identifier generator |

## Adapter Prerequisites

All session adapters must implement the `SessionAdapter` interface, The The constructor must accept an expiration parameter.

```dart
abstract class SessionAdapter {
  const SessionAdapter({
    Duration expiration,
  });

  ...
}
```

## Session operations

::: code-group

```dart [Read]
context.session.identifier; // Gets the session identifier
await context.session.has('key'); // Has a key is in the session
await context.session.get('key'); // Gets a value given a key, if not found, returns null
```

```dart [Write]
await context.session.set('key', 'value'); // Sets a value given a key
await context.session.renew(); // If called, it will be rewritten to the http response header.
```

```dart [Delete]
await context.session.remove('key'); // Removes a value given a key
await context.session.destroy(); // Destroys the session, and regenerates a new session
```

:::
