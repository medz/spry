---
title: Guide → Routing
description: Split your application using routes.
---

# Routing

{{ $frontmatter.description }}

---

Using Spry router allows more advanced and convenient routing system such as parameters and HTTP methods while the app instance itself only allows static prefix matching.

::: tip
Internally Spry uses [RoutingKit](https://github.com/medz/routingkit) for route matching.
:::

## Listen route

You can listen a HTTP request to final event handler using `app.on`:

```dart
app.on('get', '/hello', (event) => ...); // Listen GET /hello
```

If you need listen all \*_HTTP Method_ to event handler, Set the `app.on` first param to `null`:

```dart
app.on(null, '/hello', (event) => ...);
```

## Methods

Routes can be registered directly to your Spry application using various HTTP method helpers:

```dart
// Reponds to GET /foo/bar
app.get('/foo/bar', (event) {
  ...
});
```

Route handlers support returning anything type. You can specify the return type of a route using `T` This can be useful in situations where the compiler cannot determine the return type:

```dart
app.get<String>('foo', (event) {
  return 'bar';
});
```

These are the supported route helper methods:

- get
- put
- patch
- post
- delete
- head

## Path Component

Each route registration method accepts a variadic list of path component. This type is expressible by string literal and has four cases:

- Static(`foo`)
- Param(`:name`)
- Anything(`*`)
- Catchall(`**`/`**:name`)

### Static

This is a static route component. Only requests with an exactly matching string at this position will be permitted.

```dart
app.get('foo/bar/baz', () => ...);
```

### Param

This is a dynamic route component. Any string at this position will be allowed. A parameter path component is specified with a : prefix. The string following the : will be used as the parameter's name. You can use the name to later fetch the parameters value from the request.

```dart
app.get('foo/:bar/baz', (event) => ...);
```

Param path component allows mixed patterns, multiple Params can be placed in one path component:

```dart
app.get('/files/:dir/:filename.:format,v:version', (event) => ...);
```

### Anything

This is very similar to parameter except the value is discarded. This path component is specified as just `*`.

```dart
app.get('foo/*/baz', (event) => ...);
```

### Catchall

This is a dynamic route component that matches one or more components. It is specified using just `**`. Any string at this position or later positions will be matched in the request.

```dart
app.get('foo/**', (event) => ...);
```

Catchall path component allows conversion to Param path component:

```dart
app.get('foo/**:name', (event) => ...);
```
