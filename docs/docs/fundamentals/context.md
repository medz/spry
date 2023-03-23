---
title: Context
---

# Context

[[toc]]

## What is a context?

A context is an object that contains the request and response objects.

## Read request in context

You can read the request in the context:

```dart
void handler(Context context) {
  final request = context.request;
}
```

## Read response in context

You can read the response in the context:

```dart
void handler(Context context) {
  final response = context.response;
}
```

## Read Spry application in context

You can read the Spry application in the context:

```dart
void handler(Context context) {
  final spry = context.app;
}
```

## Sets a value in context

You can set a value in the context:

```dart
void handler(Context context) {
  context['key'] = 'value';
}
```

## Gets a value in context

You can get a value in the context:

```dart
void handler(Context context) {
  final value = context['key'];
}
```

## Contains a key if stored in context

You can check if a key is stored in the context:

```dart
void handler(Context context) {
  if (context.contains('key')) {
    // ...
  }
}
```

## Frameworks stored in context

| Key            | Key Type       | Value Type     | Description           |
| -------------- | -------------- | -------------- | --------------------- |
| `Spry`         | `Spry`         | `Spry`         | The Spry application. |
| `Request`      | `Request`      | `Request`      | The request.          |
| `Response`     | `Response`     | `Response`     | The response.         |
| `HttpRequest`  | `HttpRequest`  | `HttpRequest`  | The HTTP request.     |
| `HttpResponse` | `HttpResponse` | `HttpResponse` | The HTTP response.    |
| `Context`      | `Context`      | `Context`      | The context.          |
