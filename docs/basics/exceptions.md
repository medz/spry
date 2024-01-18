---
title: Basics → Errors & Exceptions
---

# Errors & Exceptions

Spry's error handling is based on the `Exception` interface. Route processing can throw or return objects that implement the `Exception`/`Error` interface through `throw`. Throwing or returning Dart's `Exception`/`Error` will result in a `500` status response.

If you want Spry to correctly change the error state on your own custom errors or exceptions, you need to implement the `AbortException` interface.

```dart
class MyException implements AbortException {
    @override
    int get status => 400;

    final String message;

    const MyException(this.message);
}
```

## Abort

Spry provides a default exception class named `Abort`, which follows the `AbortException` and `Exception` interfaces. You can initialize it with HTTP status codes and optional exception messages.

```dart
// 404 Exception, default message is "Not Found"
throw Abort(404);

// Unauthorized Exception, custom message
throw Abort(401, "Invalid Credentials");
```

Too cumbersome for jump times in `dart:io`. If you want to implement a jump without a `response` object, you can use the `Abort.redirect` method.

```dart
// Redirect to /login, default status is 302, message is "Found"
Abort.redirect("/login");

// Redirect to /login, custom status and message
Abort.redirect("/login", message: "Please login first");

// Redirect to /login, custom HTTP status
Abort.redirect("/login", status: 308);
```

## Abort Exception

By default, any `Exception`/`Error` will result in a `500 Internal Server Error` response.

You can use the `AbortException` interface to implement a series of custom exceptions, which will be handled correctly.

```dart
class UnauthorizedException implements AbortException {
    @override
    int get status => 401;

    final String message;

    const UnauthorizedException(this.message);
}
```

As in the above example, by creating the `UnauthorizedException` class and implementing the `AbortException` interface, you can correctly return the `401` status code when the exception is thrown.

::: warning

For the `30x` state, `AbortException` will not automatically jump because Spry relies on the `RedirectException` interface in `dart:io` to respond to the jump. If you want to implement a jump, you can use the `Abort.redirect` method or implement the `RedirectException` interface.

:::

## Exception Filters

Spry comes with a built-in exception layer that handles all unhandled exceptions in the application. This layer catches exceptions when they are not handled by application code and then automatically sends an appropriate user-friendly response.

```txt
                   Request → Middleware → Handler
Response ← Exception Layer ← Middleware ← Handler
```

You can customize the exception layer by implementing the `ExceptionFilter` interface.

```dart
class MyExceptionFilter implements ExceptionFilter<MyException> {
    @override
    Future<void> process(ExceptionSource<MyException> source, HttpRequest request) {
        // ...
    }
}
```

Then register `MyExceptionFilter` to the `Application` instance.

```dart
app.exceptions.addFilter(MyExceptionFilter());
```

::: tip

The registration order of filters is **very important**, because the exception layer matches filters according to the registration order. You should avoid registering more general exception filters before exception-specific filters.

:::

### Exception Source

`ExceptionSource` is the exception source received by the exception filter, which contains the detailed information of the exception. For example the `exception`, `stackTrace` and `isResponseClosed` properties.

The `exception` property is the exception object received by the exception filter, the `stackTrace` property is the stack information of the exception, and the `isResponseClosed` property is a Boolean value indicating whether the response has been closed.

### Catch everything

When you just want to change the response, creating a broader exception filter is a good choice. Since textual exceptions are built into response, you can create an exception filter that catches all `Exception` and return a JSON response.

```dart
class JsonExceptionFilter implements ExceptionFilter<Exception> {
    @override
    Future<void> process(ExceptionSource<Exception> source, HttpRequest request) async {
        final response = source.response;

        response.headers.contentType = ContentType.json;
        response.write(jsonEncode({
            "message": source.exception.toString(),
        }));
    }
}
```

## Rethrow Exception

In your Exception filter, especially a broad filter, you may want to pass exceptions to other filters for handling. You can throw the `RethrowException` class to achieve this functionality.

```dart
class MyExceptionFilter implements ExceptionFilter<Exception> {
    @override
    Future<void> process(ExceptionSource<Exception> source, HttpRequest request) async {
        // ...
        throw RethrowException();
    }
}
```
