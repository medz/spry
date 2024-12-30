---
title: Getting Started
---

# Getting Started

Getting started with Spry.

## Installation

Install Spry run this command:

```bash
dart pub add spry
```

Or, update your `pubspec.yaml` file:

```yaml
dependencies:
  spry: <latest | ^{version}>
```

## Quick Start

Creates a new file `app.dart`:

<<< ../example/app.dart

Now run the development server using `dart run`:

```bash
dart run app.dart
```

And tadaa! We have a web server running locally.

## What happened?

Okay, let's now break down our example:

We first created an [Spry application][/guide/app] using `createSpry()`.
`app` is a tiny server capable of matching requests, generating response and handling lifecycle hooks (such as errors):

```dart
final app = createSpry();
```

Then we adds our first endpoint. in Spry, we define request handlers using a closure preceded by a `FutureOr<T> Function(Event)` type:

```dart
app.get('/', (event) => ...);
```

What is beautiful in Spry is that all you have to do to make a response, is to simply return it! Responses can be simple string, JSON objects, Uint8List or streams.

```dart
return '⚡️ Tadaa!';
```
