---
title: Basics → Routing
---

# Routing

Routing is the process of finding an appropriate request handler for an incoming request. The routing core of Spry is a high-performance Trie-node router based on [RoutingKit](https://pub.dev/packages/routingkit).

[[toc]]

## Overview

To understand how routing works in Spry, first you should understand the basics about HTTP requests. Take a look at the sample request below:

```http
GET /hello/spry HTTP/1.1
host: spry.fun
content-length: 0
```

This is a simple `GET` HTTP request to `/hello/spry`. If you enter the URL below into your browser's address bar, your browser will send this request.

```http
http://spry.fun/hello/spry
```

### HTTP Method

The first part of the request is the HTTP method. `GET` is the most common HTTP method, here are some other common HTTP methods:

- `GET`: Get a resource
- `POST`: Create a resource
- `PUT`: Update a resource
- `DELETE`: Delete a resource
- `PATCH`: Update some properties of a resource

### Request Path

After the HTTP method is the request's URI. It consists of a path starting with `/` and an optional query string after `?`. The HTTP method and path are what Spry uses to route requests.

### Router Methods

Let's see how this request is handled in Spry:

```dart
app.get('/hello/spry', (request) {
    return 'Hello, Spry!';
});
```

All common HTTP methods can be used as methods of `Application`. They accept a string representing the path, separated by `/`.
Note that `Application` and `RoutesBuilder` do not build in all HTTP methods, you can use `on` to write manually:

```dart
app.on(
    method: "get", path: "/hello/spry",
    (request) => "Hello, Spry!",
);
```

After registering this route, the sample HTTP request above will get the following HTTP response:

```http
HTTP/1.1 200 OK
content-length: 12
content-type: text/plain; charset=utf-8

Hello, Spry!
```

### Route Parameters

Now that we've successfully routed requests based on HTTP method and path, let me try to make the path dynamic.

::: warning

The `spry` name is hardcoded in both the path and the response. Let's make it dynamic so that you can access `/hello/<any name>` and get a response.

:::

```dart
app.get('/hello/:name', (request) {
    final name = request.params.get("name");
    return 'Hello, $name!';
});
```

By using a path segment prefixed with `:` we indicate to the route that this is a dynamic path parameter. Now, any string provided here will match this route. We can then access the value of the string using `request.params`.

If we run the sample request again, you will still get a response greeting `spry`. But now you can add any name after `/hello/` and see it in the response. Let's try `/hello/dart`.

::: code-group

```http [request]
GET /hello/dart HTTP/1.1
content-length: 0
```

```http [response]
HTTP/1.1 200 OK
content-length: 12

Hello, dart!
```

:::

Now that you know the basics, check out the other sections to learn more.

## Routes

### Methods

You can use a variety of HTTP method helpers to register routes directly to your Spry `Application`:

```dart
app.get("/foo/bar", (request) {
    // ...
});
```

Route handlers support you to return any `Responsible` content, including `String`, `Map`, `List`, `File`, `Stream`, etc.

You can also specify the type of the return value of the route handler through the `T` type parameter:

```dart
app.get<String>("/foo", (request) {
    return "bar";
});
```

This is a list of built-in HTTP methods:

- `get`
- `post`
- `put`
- `patch`
- `delete`
- `head`

Procesing HTTP method helpers, there is also an `on` function that accepts the HTTP method as an input parameter:

```dart
app.on(
    method: "get",
    path: "/foo/bar",
    (request) => { ... },
);
```

### Path Segments

Each route registration method accepts a string representation of `Segment`, and has the following four situations:

- Constant (`foo`)
- Parameter (`:foo`)
- Anything (`*`)
- Catchall (`**`)

#### Constant Segment

This is a static Segment, only requests with an exact match string at this location are allowed.

```dart
app.get("/foo/bar", (request) {
    // ...
});
```

#### Parameter Segment

This is a parameter Segment, any string at this location will be allowed. Parameter Segment is specified with a `:` prefix, the string after `:` will be used as the parameter name.

```dart
app.get("/foo/:bar", (request) {
    // ...
});
```

#### Anything Segment

This is the same as the Parameter Segment, except that the parameter value is discarded. It is specified with a `*` prefix.

```dart
app.get("/foo/*/baz", (request) {
    // ...
});
```

#### Catchall Segement

This is a dynamic route component that matches one or more Segments, specified with `**`. Any string in the request will be allowed to match this location or after this location.

```dart
// GET /foo/bar
// GET /foo/bar/baz
// ...
app.get("/foo/**", (request) {
    // ...
});
```

### Parameters

When using parameter Segment (prefixed with `:`), the URI value for that location will be stored in `request.params`. You can access the value using the name in Path Sgements:

```dart
app.get("/foo/:bar", (request) {
    final bar = request.params.get("bar");
    // ...
});
```

:: tip

We can be sure that `request.params.get` will never return `null` here because our path contains `:bar`. But if the parameter is processed in advance by middleware or other programs, we need to consider the `null` situation.

:::

Values matched via Catchall (`**`) or Anything (`*`) Segment will be stored in `request.params` as `Iterable<String>`. You can access them using `request.params.catchall`:

```dart
app.get("/foo/**", (request) {
    final catchall = request.params.catchall;
    // ...
});
```

::: tip

If your path contains multiple Parameter Segments, such as `/foo/:bar/:bar`, you use `request.params.get('bar')` only returns the first value, you can use `request.params.getAll('bar')` to get all values.

:::

### Body

Spry not create a new HTTP request, in `dart:io`, `HttpRequest` itself is a `Stream`. You can read the stream data of the request directly.

```dart
app.post("/foo", (request) async {
    await (final chunk in request) {
        request.response.write(chunk);
    }
});
```

You can also send a `Stream` as the body of the response when the Handler returns `Stream`:

```dart
app.post("/foo", (request) {
    return File("foo.txt").openRead();
});
```

Of course, you can return any data without calling `write` or other methods of `request.response`. It supports `String`, `Map`, `List`, `File`, `Stream<List<int>>`, etc. Of course, you can return an instance that implements `Responsible`.

### Case Insensitive Routing

By default, Spry's routes are case-insensitive. If you want to maintain case-sensitivity, please configure it before calling `app.listen()`:

```dart
app.routes.caseSensitive = true;
```

### View All Routes

Do you want to view all registered routes? You can use the `app.routes` property to view all registered routes:

```dart
for (final route in app.routes) {
    print('${route.method} ${route.path}');
}
```

## Route Groups

Route grouping allows you to create a group of routes with specific route prefixes or specific middleware. The grouping function supports both builder and closure syntax.

All grouping methods return a `RoutesBuilder` instance, which means you can infinitely mix, match, and nest groups with other route building methods.

::: tip

Route groups can help you better organize your routes, but they are not required.

:::

### Path Prefix

Path prefix routing groups allow you to add a prefix path before a routing group.

```dart
final users = app.groupd(path: "/users");

// GET /users
users.get("/", (request) => ...);

// POST /users
users.post("/", (request) => ...);

// GET /users/:id
users.get("/:id", (request) => ...);
```

Any path component you can pass to helper methods such as `get`, `post` can be passed to `groupd`.
There is another syntax based on closures:

```dart
app.group(path: "/users", (routes) {
    // GET /users
    routes.get("/", (request) => ...);

    // POST /users
    routes.post("/", (request) => ...);

    // GET /users/:id
    routes.get(":id", (request) => ...);
});
```

Nested path prefixes allow you to define your CRUD API more concisely:

```dart
app.group(path: "/users", (users) {
    // GET /users
    users.get('/', (request) => ...);
    // POST /users
    users.post('/', (request) => ...);

    users.group(path: ":id", (user) {
        // GET /users/:id
        user.get('/', (request) => ...);
        // PUT /users/:id
        user.put('/', (request) => ...);
        // DELETE /users/:id
        user.delete('/', (request) => ...);
    });
});
```

### Middleware

In addition to path prefixes, routing groups also allow you to add middleware to routing groups.

```dart
app.get('fast-thing', (request) => ...);
app.group(middleware: [SlowMiddleware()], (routes) {
    routes.get('slow-thing', (request) => ...);
});
```

This is particularly useful for protecting a subset of routes with different authentication middleware.

```dart
app.post('/login', (request) => ...);

final auth = app.groupd(middleware: [AuthMiddleware()]);
auth.get('/profile', (request) => ...);
auth.get('/logout', (request) => ...);
```

## Redirects

Redirects are particularly useful in many scenarios. There is a `redirect` method defined in `HttpResponse` of `dart:io`, which you can use to redirect to another URL.

```dart
app.get('/foo', (request) {
    return request.response.redirect(Url.parse("/bar"));
});
```

But it’s not practical enough, so `Spry` also allows you to throw `RedirectException` in `dart:io` to implement redirection:

```dart
app.get('/foo', (request) {
    throw RedirectException("<message>", [
        RedirectInfo(...),
        ...
    ]);
});
```

::: warning

`RedirectInfo` is an abstract class in `dart:io`, you need to implement it yourself.

:::

Of course, since Spry has the magic, you can use `Abort.redirect` to simplify redirection:

```dart
app.get('/foo', (request) {
    throw Abort.redirect('/bar');
});
```
