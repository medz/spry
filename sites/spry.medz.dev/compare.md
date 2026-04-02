---
title: Spry vs Other Dart Server Options
description: Compare Spry with Shelf, Dart Frog, and Serverpod across routing model, runtime targets, generated output, API contracts, and project fit.
---

# Spry vs Other Dart Server Options

Spry is not trying to replace every Dart backend tool. It is for teams that want file routing, explicit generated output, cross-runtime deployment, and API contracts that stay close to the real route tree.

If you are evaluating Spry, the most useful question is not "which framework is best?" It is "which tradeoff model matches this project?"

## Short version

| Option | Best when you want | Tradeoff |
| --- | --- | --- |
| `Spry` | File routing, inspectable generated output, cross-runtime deployment, OpenAPI plus typed clients | Less batteries-included than a larger application platform |
| `Shelf` | A low-level HTTP toolkit with maximum control and minimal framework opinion | You assemble routing, structure, and conventions yourself |
| `Dart Frog` | A fast-to-start file-routing experience focused on Dart server apps | Less emphasis on inspectable generated output and cross-runtime target breadth |
| `Serverpod` | A full-stack backend platform with ORM, auth patterns, RPC, and broader application scaffolding | Heavier platform model and less focus on runtime portability |

## Feature view

| Capability | Spry | Shelf | Dart Frog | Serverpod |
| --- | --- | --- | --- | --- |
| File routing | Yes | No built-in | Yes | No |
| Explicit generated output | Yes | No | Not the core model | Platform-generated pieces, but different abstraction level |
| Cross-runtime targets | Dart VM, Node.js, Bun, Deno, Cloudflare Workers, Vercel, Netlify | Mostly depends on your stack choices | Primarily Dart server workflow | Primarily Serverpod platform workflow |
| Scoped middleware and errors by filesystem | Yes | No built-in | File-based middleware patterns | Platform-specific patterns |
| OpenAPI generation | Yes | Not built-in | Varies by add-ons | Different API model |
| First-party typed client generation | Yes | Not built-in | Not a core built-in promise | Platform-driven client story |
| Batteries-included app platform | No | No | No | Yes |

## Spry vs Shelf

Choose `Shelf` when you want a low-level HTTP toolkit and prefer composing your own routing, middleware, and app structure from smaller parts.

Choose `Spry` when you want:

- file routing instead of imperative route registration
- a stronger authoring convention for route layout and scoped behavior
- generated runtime output you can inspect during debugging and deployment
- built-in OpenAPI and typed client generation tied to the real route tree
- optional deployment across JavaScript and edge runtimes without redesigning the project structure

The practical difference is that Shelf gives you primitives, while Spry gives you a project model.

## Spry vs Dart Frog

Choose `Dart Frog` when you want a lightweight file-routing experience centered on a straightforward Dart server workflow and that model already matches your deployment and API-documentation needs.

Choose `Spry` when your evaluation criteria include:

- inspectable generated app and entry files
- a wider runtime target matrix
- first-party OpenAPI generation
- first-party typed client generation
- a framework story built around "one route tree, multiple deployment targets"

The practical difference is emphasis. Both care about developer experience, but Spry leans harder into explicit build artifacts, runtime portability, and API contract generation.

## Spry vs Serverpod

Choose `Serverpod` when you want a larger backend platform with stronger built-in application scaffolding, such as a more opinionated full-stack model.

Choose `Spry` when you want:

- a thinner server framework instead of a broader application platform
- filesystem-driven routing and scoped request behavior
- more control over how much abstraction sits between route code and runtime output
- flexibility to target runtimes outside a single platform model

The practical difference is scope. Serverpod aims to provide more of the application stack. Spry is intentionally narrower and sharper.

## Which one should you pick?

Pick `Spry` if most of these are true:

- you want file routing in Dart
- you care about generated output being visible and understandable
- you may need to deploy the same app to more than one runtime target
- you want OpenAPI and typed clients generated from the real route model
- you do not want a large batteries-included platform

Pick `Shelf` if most of these are true:

- you want the least framework opinion possible
- you are comfortable assembling your own routing and project conventions
- you want low-level control more than default structure

Pick `Dart Frog` if most of these are true:

- you want a simple file-routing developer experience
- your deployment story is already straightforward
- generated output and cross-runtime targets are not the main buying criteria

Pick `Serverpod` if most of these are true:

- you want a fuller backend platform
- you value built-in application scaffolding over a thinner framework core
- platform breadth matters more than staying close to raw route and runtime structure

## The honest boundary

Spry is strongest when you want boring folders, explicit output, deployment optionality, and API contracts that stay close to the route tree.

It is not trying to win by bundling the most subsystems. It is trying to win by keeping the server model small, legible, and portable.

## Next steps

- [Why Spry](/what-is-spry) if you want the positioning summary
- [Getting Started](/getting-started) if you want to run a project now
- [File Routing](/guide/routing) if route structure is the main reason you are evaluating Spry
- [Deploy Overview](/deploy/) if runtime flexibility is the key requirement
