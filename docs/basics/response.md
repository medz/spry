---
title: Basics → Response
---

# Response

Spry's response object is the `HttpResponse` object from `dart:io`. We assume that you are already familiar with it. If you are not familiar with it, you can check out [dart:io → HTTP Response](https://api.dart.dev/stable/dart-io/HttpResponse-class.html) documentation.

Throughout the request cycle, Response has no special magic, because in the design of `dart:io`, `HttpResponse` is based on `IOSink`, which is good enough to use!

But `IOSonk` has a defective design, that is, we don’t know when `IOSink` has been closed. So we added an `isClosed` attribute to `HttpResponse` to determine whether `IOSink` has been closed.

```dart
if (!response.isClosed) {
     response.write("Hello World!");
}
```

It is very useful for post-post middleware. We can determine whether it has been closed to avoid exceptions caused by writing input when it is closed.
