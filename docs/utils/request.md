---
title: Utils → Request
description: Utilities to access incoming request.
---

# Request

{{ $frontmatter.description }}

## `useRequest`

Reads current `Request` object.

**Example**:

```dart
app.use((event) {
    final request = useRequest(event);
});
```

## `useHeaders`

Reads current request event `Headers`.

**Example**:

```dart
app.use((event) {
    final headers = useHeaders(event);
});
```

## `getClientAddress`

Gets current request event client address.

> If result is not `null`, the value formated of `<ip>:<port>`.

**Example**:

```dart
app.use((event) {
    final address = getClientAddress(event);
});
```

## `useRequestURI`

Returns the `Uri` for current request event.

**Example**:

```dart
app.use((event) {
    final uri = useRequestURI(event);
});
```

## `useParams`

Returns the request event matched route params.

**Example**:

```dart
app.use((event) {
    final params = useParams(event);
});
```
