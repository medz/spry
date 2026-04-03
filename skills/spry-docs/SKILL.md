---
name: spry-docs
description: Guidance for building, debugging, and documenting Spry applications. Use when answering questions about Spry project structure (`routes/`, `middleware/`, `public/`, `hooks.dart`, `spry.config.dart`), file routing, scoped/global middleware and error handling, OpenAPI/client generation, runtime targets, generated `.spry/` output, or common troubleshooting.
---

# Spry Docs

> Based on the Spry docs, examples, and repository source. Start with
> `spry.config.dart`, the app tree, and the docs before inspecting generated
> output or framework internals.

## Preferences

- Match the user's language.
- Prefer Spry app guidance over framework-maintainer guidance.
- Check `spry.config.dart` before assuming default directories, output paths, or
  target behavior.
- Use `routes/`, `middleware/`, `public/`, `hooks.dart`, and `.spry/` as the
  core mental model.
- Provide the smallest runnable snippet or patch that answers the task.
- Inspect generated `.spry/` output only when emitted runtime files, target
  wrappers, OpenAPI artifacts, or generated clients need proof.
- Escalate to framework internals only when the docs, examples, and app source
  still do not explain the behavior.

## Core

| Topic | Description | Reference |
| --- | --- | --- |
| Project layout | Source-of-truth order for app questions | [project-layout](references/recipes.md#project-layout-and-source-of-truth) |
| Routing | Route files, params, wildcards, and route changes | [routing](references/recipes.md#add-or-change-a-route) |
| Middleware & errors | Global vs scoped middleware and `_error.dart` usage | [middleware-errors](references/recipes.md#choose-global-vs-scoped-middleware-or-error-handling) |
| OpenAPI | Configure document output and route metadata | [openapi](references/recipes.md#configure-openapi-output) |
| Client generation | Generate or debug typed clients | [client-generation](references/recipes.md#configure-client-generation) |
| Runtime targets | Switch targets and verify deploy output | [runtime-targets](references/recipes.md#change-runtime-target-or-deploy-output) |

## Tooling

| Topic | Description | Reference |
| --- | --- | --- |
| Generated output | When to inspect `.spry/` or configured output | [generated-output](references/recipes.md#decide-when-to-inspect-generated-spry-output) |
| Validation | Default validation commands for Spry apps | [validation](references/recipes.md#validation-checklist) |

## Quick Reference

### Common app layout

```text
.
├─ routes/
├─ middleware/
├─ public/
├─ hooks.dart
├─ spry.config.dart
└─ .spry/
```

### Minimal route

```dart
import 'package:spry/spry.dart';

Response handler(Event event) {
  return Response.json({'path': event.url.path});
}
```

### Minimal config

```dart
import 'package:spry/config.dart';

void main() {
  defineSpryConfig(target: BuildTarget.vm);
}
```

## Response workflow

1. Identify whether the task is about routing, middleware, OpenAPI, client
   generation, runtime targets, or emitted output.
2. Inspect `spry.config.dart` and the matching app files first.
3. Read the matching docs/examples from `references/recipes.md`.
4. Inspect generated `.spry/` output only when the task depends on emitted
   files or target wrappers.
5. Escalate to framework source only when the behavior still looks unexplained
   or like a framework bug.
