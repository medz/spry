---
title: Deploy → Dart
description: Run Spry on the Dart VM directly, or compile to a native executable or snapshot for production.
---

# Dart

Spry has five Dart-native targets. They share the same route pipeline and differ only in how the compiled server is delivered.

All targets generate source under `.spry/src/`. The `exe`, `aot`, `jit`, and `kernel` targets also compile it to a binary or snapshot under `.spry/dart/`.

## Dart VM

`BuildTarget.vm` skips compilation entirely. Spry generates source files and the server runs directly with `dart run`.

<<< ../../../example/dart_vm/spry.config.dart

**Output:**
```text
.spry/src/
  app.dart
  hooks.dart
  main.dart
```

**Run:**
```bash
dart run spry serve          # development
dart run .spry/src/main.dart # production
```

Best for local development and self-hosted environments where the Dart SDK is already present. Static assets are served from `publicDir` at the project root — run the binary from the project root to avoid path drift.

---

## Native executable

`BuildTarget.exe` compiles to a self-contained native executable. No Dart SDK required on the target machine.

```dart
import 'package:spry/config.dart';

void main() {
  defineSpryConfig(target: BuildTarget.exe);
}
```

**Output:**
```text
.spry/dart/
  server     ← native executable
  public/    ← copied from publicDir
```

**Run:**
```bash
dart run spry build
./.spry/dart/server
```

The executable and `public/` directory are everything you need to deploy. On Linux/macOS make sure the binary has execute permission (`chmod +x .spry/dart/server`). This is usually the right choice for Docker images and CI-produced release artifacts.

---

## AOT snapshot

`BuildTarget.aot` compiles to an AOT snapshot. Requires `dartaotruntime` on the target machine, but not the full SDK.

```dart
import 'package:spry/config.dart';

void main() {
  defineSpryConfig(target: BuildTarget.aot);
}
```

**Output:**
```text
.spry/dart/
  server.aot
  public/
```

**Run:**
```bash
dart run spry build
dartaotruntime .spry/dart/server.aot
```

`dartaotruntime` must be from the same Dart release used during the build — version mismatches will fail at startup.

---

## JIT snapshot

`BuildTarget.jit` compiles to a JIT snapshot. Requires the Dart VM but avoids re-parsing source on every startup.

```dart
import 'package:spry/config.dart';

void main() {
  defineSpryConfig(target: BuildTarget.jit);
}
```

**Output:**
```text
.spry/dart/
  server.jit
  public/
```

**Run:**
```bash
dart run spry build
dart run .spry/dart/server.jit
```

---

## Kernel snapshot

`BuildTarget.kernel` compiles to a kernel snapshot — the most portable Dart snapshot format. Runs on any compatible Dart VM regardless of platform.

```dart
import 'package:spry/config.dart';

void main() {
  defineSpryConfig(target: BuildTarget.kernel);
}
```

**Output:**
```text
.spry/dart/
  server.dill
  public/
```

**Run:**
```bash
dart run spry build
dart run .spry/dart/server.dill
```

---

## Choosing a target

| Target | Needs at runtime | Startup | Best for |
|---|---|---|---|
| `vm` | Dart SDK | Interpreted | Development, SDK-available hosts |
| `exe` | Nothing | Fastest | Docker, portable releases |
| `aot` | `dartaotruntime` | Fast | Cold-start sensitive, no full SDK |
| `jit` | Dart VM | Medium | Snapshot without AOT complexity |
| `kernel` | Dart VM | Slower | Maximum portability |
