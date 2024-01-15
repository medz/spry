---
title: Interceptor
---

# Interceptor

[[toc]]

## What is an interceptor?

Interceptors have a set of capabilities inspired by [Aspect Oriented Programming (AOP)](https://en.wikipedia.org/wiki/Aspect-oriented_programming) techniques.

The main purpose of its design is to intercept exceptions and errors, allowing errors to be defined and responded in a better way.

## Import interceptor

To use the interceptor, you must import the `spry` package:

```dart
import 'package:spry/interceptor.dart';
```

## Exception filter

Exception filters allow you to filter individually for a certain type of exception or error, and then you have to handle the exception:

::: code-group

```dart [Filter]
class CustomExceptionFillter extends ExceptionFilter<CustomException> {
  const CustomExceptionFillter();

  @override
  Future<void> handle(Context context, CustomException exception, StackTrace stack) async {
    context.response.statusCode = 400;
    context.response.text('Custom exception');
  }
}
```

```dart [Exception]
class CustomException implements Exception {
  const CustomException();
}
```

```dart [Throw]
void handler(Context context) {
  throw const CustomException();
}
```

```dart [Use]
final spry = Spry();

spry.use(const CustomExceptionFillter());
```

:::

## Exception handler

Exception handlers allow you to handle all exceptions and errors, and then you have to handle the exception:

::: code-group

```dart [Handler]
class MyExceptionHandler extends ExceptionHandler {
  const MyExceptionHandler();

  @override
  Future<void> handle(Context context, Object exception, StackTrace stack) async {
    context.response.statusCode = 400;
    context.response.write('My exception');
  }
}
```

```dart [Throw]
void handler(Context context) {
  throw Exception();
}
```

```dart [Use]
final spry = Spry();

final exceptionHandler = const MyExceptionHandler();
final interceptor = Interceptor(handler: exceptionHandler);

spry.use(interceptor);
```

:::

## Built-in exception handlers

| Exception handler                   | Description                                                                    |
| ----------------------------------- | ------------------------------------------------------------------------------ |
| `ExceptionHandler.onlyStatusCode()` | Returns an exception handler that only returns the status code.                |
| `ExceptionHandler.plainText()`      | Returns an exception handler that returns the exception message as plain text. |
| `ExceptionHandler.json()`           | Returns an exception handler that returns the exception message as JSON.       |

## Rethrow exception

If you need to avoid handling a certain type of exception or error in your exception filter or exception handler, you should throw a `RethrowException`:

::: code-group

```dart [Filter]
class CustomExceptionFillter extends ExceptionFilter<CustomBaseException> {
  const CustomExceptionFillter();

  @override
  Future<void> handle(Context context, CustomBaseException exception, StackTrace stack) async {
    if (exception is MyCustomException) {
      throw const RethrowException();
    }

    context.response.statusCode = 400;
  }
}
```

```dart [Exception]
abstract class CustomBaseException implements Exception {
  const CustomBaseException();
}

class MyCustomException extends CustomBaseException {
  const MyCustomException();
}
```

```dart [Throw]
void handler(Context context) {
  throw const MyCustomException();
}
```

```dart [Use]
final spry = Spry();

spry.use(const CustomExceptionFillter());
```
