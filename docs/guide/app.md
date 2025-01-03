---
title: Guide → App Instance
description: App instance is the core of a Spry.
---

# App Instance

{{ $frontmatter.description }}

---

The core of a Spry is an `app` instance. It is the core of the server that handles incoming requests. You can use app instance to register event handlers.

## Initializing an app

You can create a new Spry app instance using `createSpry` utility:

```dart
final app = createSpry();
```

## Registering middleware

You can register middleware to app instance use `app.use`:

```dart
app.use((event) => 'Hello Spry!');
```

## Routing

To learn about routing, see the [Routing guide](/guide/routing).

## Internals

::: tip
This details are mainly informational. never directly use internals for production applications!
:::

::: warning
As it is an internal exposed detail, it may change at any time.
:::

Spry app instance has some additional properties. However it is usually not recommended to directly access them unless you know what are you doing!

* `app.middleware`: App middleware router context.
* `app.router`: App handler router context.
