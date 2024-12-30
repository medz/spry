---
title: Deploy
description: Spry is designed to be cross-platform, this chapter will guide you on how to deploy on other runtimes.
---

# Deploy

{{ $frontmatter.description }}

Below, we will use a file named `server.dart` as a demonstration, its content is:

<<< ../example/app.dart

## Dart VM

By default, in Dart VM you must compile and deploy, just run the following command:

```bash
dart run server.dart
```

## Native (Binary Executable)

You can directly run the following command to compile it into a **native** binary executable:
```bash
dart compile exe server.dart -o server
```

If you have a specific target OS, you can add the `--target-os` parameter:

```bash
dart compile exe server.dart -o server --target-os [Your target OS]
```

For example, macOS:
```bash
dart compile exe server.dart -o server --target-os macos
```

## JavaScript runtime

Currently, Spry supports [Node.js](https://nodejs.org/), [Deno](https://deno.com/), and [Bun](https://bun.sh/) JavaScript runtimes.

We use the following command to transpile `server.dart` to `server.js`:

```bash
dart compile js server.dart -o server.js
```

It will automatically recognize the runtime platform internally, you just need to run it:

::: code-group
```bash [Bun]
bun run server.js
```
```bash [Node.js]
node server.js
```
```bash [Deno]
deno run --allow-net server.js
```
:::
