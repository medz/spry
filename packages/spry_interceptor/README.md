# Spry interceptor

Exception interceptor for Spry, which intercepts exceptions and errors and writes response to prevent unexpected application interruption.

[![pub package](https://img.shields.io/pub/v/spry_interceptor.svg)](https://pub.dartlang.org/packages/spry_interceptor)

> Why do you need an interceptor?
>
> Spry has built-in error interception, but it's not friendly enough. Sometimes we encounter an exception and need to output a friendly error message instead of directly outputting the exception message.

## Example

```dart
import 'package:spry/spry.dart';
import 'package:spry_interceptor/spry_interceptor.dart';

void main() {
   final Spry spry = Spry();
   final Interceptor interceptor = Interceptor(
     handler: ExceptionHandler.json(),
   );

   handler(Context context) {
     throw HttpException.forbidden();
   }

   spry.use(interceptor);
   spry.listen(handler, port: 3000);

   print('Listening om http://localhost:3000');
}
```

When we visit `http://localhost:3000`, we will get the following results:

```json
{
   "status": 403,
   "message": "Forbidden"
}
```

## Interceptors

The interceptor has only one property `handler`, which is an `ExceptionHandler` object.

We use `ExceptionHandler` to handle exceptions and report them to the user. For example, API interface, we can return error information in JSON format:

```dart
final Interceptor interceptor = Interceptor(
   handler: ExceptionHandler.json(),
);

spry.use(interceptor);
```

##Exception Handler

`ExceptionHandler` is an abstract class that specifies the behavior of an interceptor. Try creating a custom exception handler:

```dart
class MyExceptionHandler implements ExceptionHandler {
   @override
   void call(Context context, Object exception, StackTrace stackTrace) {
     final Response response = context. response;

     response.status(500);
     response. send('Something went wrong');
   }
}

final Interceptor interceptor = Interceptor(
   handler: MyExceptionHandler(),
);

spry.use(interceptor);
```

Now, when we access the exception interface, we will get the following results:

```text
status: 500 internal server error

Something went wrong
```

### Built-in exception handlers

- `ExceptionHandler.json()`: returns an error message in JSON format
- `ExceptionHandler.plainText()`: returns an error message in text format
- `ExceptionHandler.onlyStatusCode()`: returns only the status code

## exception filter

Sometimes, we don't want all exceptions to be intercepted by the interceptor, or we want to intercept a specific exception or handle a specific exception. We can do this with `ExceptionFilter`.

```dart
class MyExceptionFilter extends ExceptionFilter<HttpException> {
   @override
   void call(Context context, HttpException exception, StackTrace stackTrace) {
     final Response response = context. response;

     response.status(exception.statusCode);
     response.send(exception. message);
   }
}

spry.use(MyExceptionFilter());
```

The exception filter is a standard Spry middleware that does not depend on interceptors. We can use it anywhere.

### Functional exception filter

Inheriting the `ExceptionFilter` class is a bit cumbersome, we can use a functional exception filter:

```dart
final filter = ExceptionFilter<HttpException>.fromHandler((context, exception, stackTrace) {
   final Response response = context. response;

   response.status(exception.statusCode);
   response.send(exception. message);
});

spry.use(filter);
```