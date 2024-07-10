---
title: Basics → Handler
---

# Handler

After creating an app instance, you can start defining your application logic using event handlers.
An event handler is a function that receive an `Event` instance and returns a response. You can compare it to controllers in other frameworks.

## Defining event handlers

You can define event handlers using `Handler` interface.

```dart
class MyHandler implements Handler {
    Future<Response> handle(Event event) async {
        return Response.text('Result string');
    }
}
```

But usually you don't need to do this. Because Spry's logic registration API provides a simpler closure type method:

```dart
app.use((event) {
    return 'Result string';
});
```

## Responsible

Values returned from event handlers are automatically converted to responses. It can be:

* JSON serializable value. If returning a JSON object or serializable value, it will be stringified and sent with default `application/json` content-type.
* `String`/`num`/`bool`: Sent as-is using default `text/plain` content-type.
* `Map`/`List`: Sent as-is using default `application/json` content-type.
* `null`/`void`: Spry with end response with `204 - No Content` status code.
* Any `Object` include `toJson()` method: Sent as-is using default `application/json` content-type.
* `Stream<List<int>>`
* `Responsible`

Any of above values could also be wrapped in a `Future`. This means that you can return a `Future` from your event handler and Spry will wait for it to resolve before sending the response.

**Example**: Send text response:

```dart
app.use((event) => 'Hello, Spry!');
app.use((event) => 1);
app.use((event) => 2.1);
app.use((event) => true);
```

**Example**: Send JSON response:

```dart
app.use((event) => {"url": event.uri.toString()});
app.use((event) => [1, 2, 3]);

class User {
    late String name;

    toJson() => {'name': name};
}
app.use((event) => User()..name = 'Bob');
```

**Example**: Send a Future value:

```dart
app.use((event) {
    final completer = Completer();
    Timer(Duration(seconds: 1), () {
      completer.complete('One second later');
    });

    return completer.future;
});
```

**Example**: Send a Stream:

```dart
app.use((event) {
    return File("foo.txt").openRead();
});
```

## Handlers stack

In Spry, we abandoned the so-called middleware design and designed the concept of Handlers stack, where each layer interrupts the call by default.

```dart
app.use((event) => 'value');
app.use((event) => 'value 2'); // Will never be executed!
```

The app expects that each Handler call will return a value, so the Handler needs to actively tell the app to call the next Handler (using the `next` function):

```dart
app.use((event) {
    print(1);

    return next(event);
});
app.use((event) {
    print(2);
});

// console: 1, 2
```

It can also perform functions similar to After-middleware:

```dart
app.use((event) async {
    final res = next(event);
    print(1);

    return res;
});
app.use((event) {
    print(2);
});

// console: 2, 1
```
