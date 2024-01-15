---
title: Advanced → Middleware
---

# Middleware

Middleware is a logical chain between request/response and handler. It allows you to perform some operations before the request reaches the handler or after it leaves the handler.

## Configiration

You can use `app.middleware.use` to add a Middleware to all Handlers.

```dart
app.middleware.use(MyMiddleware());
```

You can also add Middleware to a routing group or a single route through `app.group`/`app.groupd`.

```dart
app
    .groupd(middleware: [MyMiddleware()])
    .get("/user", (req, res) => res.ok("Hello"));
```

### Ordering

The order of adding Middleware is very important. Before entering the Handler, the order of adding Middleware will be executed. After leaving the Handler, the order of adding Middleware will be executed in the reverse order.

```dart
app.middleware.use(MyMiddleware1());
app.middleware.use(MyMiddleware2());

app.get("/user", (req, res) => res.ok("Hello"));
```

`GET /user` request will be executed in the following order:

```txt
MyMiddleware1 → MyMiddleware2 → Handler → MyMiddleware2 → MyMiddleware1
```

In the routing group, it is easy for us to control the order of Middleware, but the order of global Middleware is not so easy to control. In order to solve this problem, you can pass the `prepend` parameter to `app.middleware.use` to control it.

```dart
app.middleware.use(<middleware>, prepend: true);
```

This way, the middleware will be added at the top of the stack instead of the bottom.

## Creating Middleware

To create a middleware, you should implement the `Middleware` interface:

```dart
class MyMiddleware implements Middleware {
    @override
    Future<void> process(HttpRequest request, Next next) async {
        // Before ...
        await next();
        // After ...
    }
}
```

The `next` function is used to notify the next Middleware in the processing chain. If there is no next Middleware, the Handler will be executed.

::: warning

Since the result of `next` is a `Future`, you must use `await` to wait for the execution result of `next`.

If you don't want to wait for it, then you should use `return` to return the result of `next`.

> If you neither wait for the execution of `next()` nor return the result of `next()`, and your `process` is operated by other logic of `response`, then it is very likely to cause Spry to exit abnormally, and Cannot be captured.

:::

## Before middleware

Depending on the `Next` notification design, you can perform some operations before notifying the next Middleware.

```dart
class MyMiddleware implements Middleware {
    @override
    Future<void> process(HttpRequest request, Next next) async {
        // Before logic here ...

        return next();
    }
}
```

Moreover, we recommend that your front-end middleware use `return next()` to return the execution result of `next`. This avoids continuing to operate the response when the response has been closed.

## After middleware

You can perform some operations after waiting for `next()` to complete.

```dart
class MyMiddleware implements Middleware {
    @override
    Future<void> process(HttpRequest request, Next next) async {
        await next();

        // After logic here ...
    }
}
```

Please be sure to add `await next()` before your code, otherwise there is no guarantee that your middleware will be executed after the Handler.
