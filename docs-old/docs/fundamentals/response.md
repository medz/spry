---
title: Response
---

# Response

[[toc]]

## Read response in context

You can read the response in the context:

```dart
final response = context.response;
```

## Status code

You can sets the status code of the response.

```dart
response.statusCode = 200;
```

## Headers

You can send a header in the response:

```dart
response.headers.set('x-custom-header', 'value');
```

You can also send multiple headers in the response:

```dart
response.headers.add('x-custom-header', 'value1');
response.headers.add('x-custom-header', 'value2');
```

## Cookies

You can send a cookie in the response:

```dart
response.cookies.add(Cookie('name', 'value'));
```

## Content type

You can sets the content type of the response:

```dart
response.contentType = ContentType.json;
```

## Write a string in the response

You can write a string in the response:

```dart
response.text('Hello world!');
```

## Write a list of bytes in the response

You can write a list of bytes in the response:

```dart
response.raw([1, 2, 3]);
```

## Write a `Stream` in the response

You can write a `Stream` in the response:

```dart
response.stream(Stream.fromIterable([1, 2, 3]));
```

## Redirect

You can redirect a `Uri` in the response:

```dart
response.redirect(location);
```

> **Note**: The response will be sent and closed immediately after the redirect.

## Close the response

If you want to close the response, you can call the `close()` method:

```dart
response.close();
```

> **Note**: After closing the response, the middleware and all code after calling `close` will not be executed.
