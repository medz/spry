---
title: Guide → Assets
description: Use the public directory for static files that should bypass route handlers.
---

# Assets

Spry serves public assets from the `public/` directory before route handlers run for `GET` and `HEAD` requests.

## Public assets

```text
public/
  logo.svg
  hello.txt
  robots.txt
```

These files are served directly:

- `public/logo.svg` -> `/logo.svg`
- `public/hello.txt` -> `/hello.txt`
- `public/robots.txt` -> `/robots.txt`

## Why this matters

Static files should not compete with your route handlers for work they do not need to do.

Use `public/` for:

- logos and images
- robots and favicon files
- static text or download assets

## Custom asset root

If you do not want to use `public/`, change it in config:

```dart
defineSpryConfig(
  publicDir: 'static',
  target: BuildTarget.vm,
);
```

That keeps asset location configurable without changing how routes are written.
