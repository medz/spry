---
title: Response
---

# Response

Spry's `Response` object is an HTTP response, which contains the status code, header, content and other information of the response.

## statusCode

This is an attribute of type `int` which represents the status code of the response.

> The default value is `200`, and `Response.statusCode` is also a setter method, which can be used to modify the status code of the response.
>
> ```dart
> response.statusCode = 404;
> ```

## headers

This is an HttpHeaders object used to set the headers of the response.

```dart
response.headers.contentType = ContentType.html;
```

## cookies

This is a list of objects containing the response cookies.

```dart
response.cookies.add(Cookie('name', 'value'));
```

## encoding

This is an `Encoding` object that sets the encoding of the response.

## contentType

In addition to using the `headers` property to set the response headers, you can also use the `contentType` field to set the response's `Content-Type` header.

```dart
response.contentType = ContentType.html;
```

## context

This is a `Context` object which represents the current request context.

> Yes, `Context` contains a `Response` object, and `Response` contains a `Context` object, which is a circular reference. But this will not cause any problems, because the `Context` object is a property of a `Response` object, and the `Response` object is a property of a `Context` object, the life cycle of these two objects is the same, so no Will cause a memory leak.

## redirect

This is a redirection method that accepts a `Uri` object as a parameter, which represents the redirected address. There is also an optional `int` type parameter, indicating the status code of the redirection, the default value is `302`.

```dart
response.redirect(...);
```

## close

This is a close response method that is used to eagerly complete the request.

```dart
response.close();
```

> In general, there is no need to call the `close` method, because `Spry` will automatically close the response when it is complete.
> If you manually call the `close` method, then `Spry` will no longer close the response automatically, and the post-middleware will no longer be executed.

## Write raw response body

This is a method that accepts a `List<int>` object as a parameter, which represents the raw response body.

```dart
response.raw(...);
```

## Write response body as string

This is a method that accepts a `String` object as a parameter, which represents the response body as a string.

```dart
response.text(...);
```

## Write response body as Stream

This is a method that accepts a `Stream<List<int>>` object as a parameter, which represents the response body as a stream.

```dart
response.stream(...);
```

## Read write stream

This is a method that accepts a `Stream<List<int>>` object as a parameter, which represents the response body as a stream.

```dart
response.read();
```
