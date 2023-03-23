---
title: Request
---

# Request

Spry's `Request` object encapsulates the information of the HTTP request, including the request method, request path, request header, request body, etc.

[[toc]]

## Read the request

You can read the request in the context:

```dart
final request = context.request;
```

## HTTP method

The HTTP method is the method used to request a resource. The HTTP method is case-sensitive.

```dart
final method = request.method;
```

## The URI for the request

This provides access to the path and query string for the request.

```dart
final uri = request.uri;
```

## The requested URI for the request

The returned URI is reconstructed by using http-header fields, to access otherwise lost information, e.g. host and scheme.

To reconstruct the scheme, first 'X-Forwarded-Proto' is checked, and then falling back to server type.

To reconstruct the host, first 'X-Forwarded-Host' is checked, then 'Host' and finally calling back to server.

```dart
final requestedUri = request.requestedUri;
```

## HTTP protocol version

The HTTP protocol version is the version of the HTTP protocol used in the request.

```dart
final protocolVersion = request.protocolVersion;
```

## Request is empty

Whether the request is empty.

```dart
final isEmpty = request.isEmpty;
```

## Headers

The returned `HttpHeaders` are immutable.

```dart
final headers = request.headers;

print(headers.contentType);
```

## Cookies

The cookies in the request, from the "Cookie" headers.

```dart
final cookies = request.cookies;
```

## Read a stream for the request body

The request body is a stream of bytes. The stream is a single-subscription stream.

```dart
final stream = request.stream();
```

## Read the request body as a string

The `text()` method reads the request body as a string.

```dart
final text = await request.text();
```

## Read the request body as a list of bytes

The `raw()` method reads the request body as a list of bytes.

```dart
final raw = await request.raw();
```
