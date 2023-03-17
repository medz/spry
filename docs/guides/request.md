---
title: Request
---

# Request

Spry's `Request` object encapsulates the information of the HTTP request, including the request method, request path, request header, request body, etc.

## method

`Request.method` is a `String` object, which contains the request method, such as `GET`, `POST`, etc.

## uri

`Request.uri` is a `Uri` object that contains the request path.

## requestedUri

The returned URI is reconstructed by using http-header fields, to access
otherwise lost information, e.g. host and scheme.

To reconstruct the scheme, first 'X-Forwarded-Proto' is checked, and then
falling back to server type.

To reconstruct the host, first 'X-Forwarded-Host' is checked, then 'Host'
and finally calling back to server.

## protocolVersion

`Request.protocolVersion` is a `String` object that contains the requested protocol version, e.g. `1.1`.

## isEmtpy

`Request.isEmpty` is a `bool` object that indicates whether the request body is empty.

## headers

`Request.headers` is an object containing the request headers.

## cookies

`Request.cookies` is a list of objects containing the requested cookies.

## context

`Request.context` is a `Context` object that contains the context of the request.

> Yes, `Context` contains a `Request` object, and `Request` contains a `Context` object, which is a circular reference. But this will not cause any problems, because the `Context` object is a property of a `Request` object, and the `Request` object is a property of a `Context` object, the life cycle of these two objects is the same, so no Will cause a memory leak.

## Read raw request body

`Request.raw()` is a method that returns a `List<int>` object containing the raw request body.

## Read request body as string

`Request.text()` is a method that returns a `String` object containing the request body as a string.

## Read request body as Stream

`Request.stream()` is a method that returns a `Stream<List<int>>` object containing the request body as a stream.
