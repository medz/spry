---
title: Deploy → Dart
description: Run Spry on the Dart VM directly, or compile to a native executable or snapshot for production.
---

# Dart

Spry supports five Dart-native targets: one for development and four compiled production variants.

## vm

`BuildTarget.vm` generates source files and runs them directly with the Dart VM. No compilation step.

### Config

<<< ../../../example/dart_vm/spry.config.dart

### Build output

```text
.spry/
  src/
    app.dart
    hooks.dart
    main.dart
```

### Run

```bash
# Development
dart run spry serve

# Production (run generated source directly)
dart run .spry/src/main.dart
```

### Good fit

- Dart-native self-hosted environments
- Development and local iteration
- Deployments where the Dart SDK is already present

---

## exe

`BuildTarget.exe` compiles to a self-contained native executable using `dart compile exe`. No Dart SDK required at runtime.

### Config

```dart
import 'package:spry/config.dart';

void main() {
  defineSpryConfig(target: BuildTarget.exe);
}
```

### Build output

```text
.spry/
  src/
    main.dart       ← compile input
  dart/
    server          ← native executable
    public/         ← copied public assets
```

### Run

```bash
dart run spry build
./.spry/dart/server
```

### Good fit

- Docker and container deployments
- Environments without a Dart SDK
- CI/CD pipelines producing a single portable binary

---

## aot

`BuildTarget.aot` compiles to an AOT snapshot using `dart compile aot-snapshot`. Requires `dartaotruntime` at the deployment target.

### Config

```dart
import 'package:spry/config.dart';

void main() {
  defineSpryConfig(target: BuildTarget.aot);
}
```

### Build output

```text
.spry/
  dart/
    server.aot
    public/
```

### Run

```bash
dart run spry build
dartaotruntime .spry/dart/server.aot
```

---

## jit

`BuildTarget.jit` compiles to a JIT snapshot using `dart compile jit-snapshot`. Requires the Dart VM at runtime but skips re-parsing on startup.

### Config

```dart
import 'package:spry/config.dart';

void main() {
  defineSpryConfig(target: BuildTarget.jit);
}
```

### Build output

```text
.spry/
  dart/
    server.jit
    public/
```

### Run

```bash
dart run spry build
dart run .spry/dart/server.jit
```

---

## kernel

`BuildTarget.kernel` compiles to a kernel snapshot using `dart compile kernel`. Most portable of the snapshot formats — runs on any compatible Dart VM.

### Config

```dart
import 'package:spry/config.dart';

void main() {
  defineSpryConfig(target: BuildTarget.kernel);
}
```

### Build output

```text
.spry/
  dart/
    server.dill
    public/
```

### Run

```bash
dart run spry build
dart run .spry/dart/server.dill
```

---

## Choosing a Dart target

| Target | SDK at runtime | Startup | Portability |
|---|---|---|---|
| `vm` | Required | Interpreted | High |
| `exe` | Not required | Fast | Self-contained binary |
| `aot` | `dartaotruntime` | Fast | Snapshot + runtime |
| `jit` | Required | Medium | VM-specific snapshot |
| `kernel` | Required | Slower | Cross-VM portable |

For production Docker deployments, `exe` is usually the best choice. For environments that already have a Dart SDK and want the simplest path, `vm` works well.
