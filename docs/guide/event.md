---
title: Basics → Event
---

# Event

Every time a new HTTP request comes, Spry internally creates an Event object and passes it though event handlers until sending the response.

An event is passed through all the lifecycle hooks and composable utils to use it as context.

Example:

```dart
app.use((event) {
    console.log('Request: ${event.method} ${event.uri.toString()}');

    return next(event); // Call next handler.
});
```

## `event.app`

Returns the Spry instance for the request event.

## `event.locals`

A container for passing values ​​in the Handlers stack.

## `event.request`

Spry abstract Request request object.

## `event.uri`

The requested URI for the request event.

If the request URI is absolute (e.g. 'https://www.example.com/foo') then
it is returned as-is. Otherwise, the returned URI is reconstructed by
using the request URI path (e.g. '/foo') and HTTP header fields.

To reconstruct the scheme, the 'X-Forwarded-Proto' header is used.

To reconstruct the host, the 'X-Forwarded-Host' header is used. If it is
not present then the 'Host' header is used. If neither is present then
the host name of the server is used.

## `event.getClientAddress()`

Returns client address, value formated of `<ip>:port`.

The returned value comes from the Platform implementation.
if the platform does not support it, an empty string will be returned.

## `event.handlers`

Access to the normalized request handlers.

## `event.method`

Access to the normalized (uppercase) request method.

## `event.params`

Returns the [Params](/guide/routing#params) of dynamic routing.

## `event.route?`

Return [Route], when the route has not yet started matching or has not been matched to return null, usually this situation is when the route is registered and has entered the fallback processor.
