---
title: Middleware → Timing
description: Measure downstream request handling time with Spry's first-party timing middleware.
---

# Timing

`timing(...)` records downstream request handling time and writes it to the `server-timing` response header.

Import it from the first-party middleware entrypoint:

```dart
import 'package:spry/middleware.dart';
```

## What it does

By default, `timing(...)`:

- measures downstream request handling with `Stopwatch`
- writes a `server-timing` metric named `app`
- formats the duration in milliseconds
- appends to an existing `server-timing` header instead of replacing it

## Basic usage

Use it in global middleware:

```dart
// middleware/02_timing.dart
import 'package:spry/middleware.dart';
import 'package:spry/spry.dart';

final middleware = timing();
```

That produces a header like:

```http
server-timing: app;dur=12.3
```

If downstream code already sets `server-timing`, Spry appends its own metric:

```http
server-timing: db;dur=4.0, app;dur=12.3
```

## API

```dart
Middleware timing({
  String metricName = 'app',
  int fractionDigits = 1,
});
```

## Options

### `metricName`

Changes the metric name written into the `server-timing` header.

### `fractionDigits`

Controls how many decimal places are written for the duration value.

## When to use it

Use `timing(...)` when you want:

- a lightweight response-time signal
- an easy pairing with `requestId(...)`
- timing data that can coexist with other `server-timing` metrics

If you need deeper tracing or multi-phase performance breakdowns, this middleware should stay as the coarse outer timing layer rather than grow into a full tracing system.
