# Spry Configuration Reference

## spry.config.dart

Every Spry project has a `spry.config.dart` file that emits JSON config:

```dart
import 'package:spry/config.dart';

void main() => defineSpryConfig(
  host: 'localhost',
  port: 3000,
  target: BuildTarget.vm,
  routesDir: 'routes',
  middlewareDir: 'middleware',
  publicDir: 'public',
  outputDir: '.spry',
  caseSensitive: true,
  handlerCacheCapacity: 1000,
  reload: ReloadStrategy.hotswap,
);
```

## Configuration Options

| Option | Type | Default | Description |
|---|---|---|---|
| `host` | `String` | `'0.0.0.0'` | Server bind address |
| `port` | `int` | `3000` | Server port |
| `target` | `BuildTarget` | `BuildTarget.vm` | Runtime target |
| `routesDir` | `String` | `'routes'` | Routes directory |
| `middlewareDir` | `String` | `'middleware'` | Middleware directory |
| `publicDir` | `String` | `'public'` | Static assets directory |
| `outputDir` | `String` | `'.spry'` | Generated output directory |
| `caseSensitive` | `bool` | `true` | Route matching case sensitivity |
| `handlerCacheCapacity` | `int?` | `null` | LRU cache size for route lookups |
| `reload` | `ReloadStrategy` | `ReloadStrategy.restart` | Dev server reload behavior |
| `wranglerConfig` | `String?` | `null` | Cloudflare Wrangler config path |

## Build Targets

| Target | Description | Compilation |
|---|---|---|
| `vm` | Dart VM (dev mode) | None — runs source directly |
| `exe` | Native executable | `dart compile exe` |
| `aot` | AOT snapshot | `dart compile aot-snapshot` |
| `jit` | JIT snapshot | `dart compile jit-snapshot` |
| `kernel` | Kernel snapshot | `dart compile kernel` |
| `node` | Node.js | `dart compile js` → `.cjs` |
| `bun` | Bun runtime | `dart compile js` → `.js` |
| `deno` | Deno runtime | `dart compile js` → `.js` |
| `cloudflare` | Cloudflare Workers | `dart compile js` + Wrangler |
| `vercel` | Vercel Functions | `dart compile js` + Vercel CLI |
| `netlify` | Netlify Functions | `dart compile js` + Netlify CLI |

## Reload Strategies

| Strategy | Behavior |
|---|---|
| `restart` | Kills and restarts the runtime process on rebuild |
| `hotswap` | Keeps the process alive when target supports it (CF Workers, Vercel, Netlify) |

## OpenAPI Configuration

```dart
import 'package:spry/config.dart';

void main() => defineSpryConfig(
  openapi: OpenAPIConfig(
    document: OpenAPIDocumentConfig(
      info: OpenAPIInfo(title: 'My API', version: '1.0.0'),
    ),
    output: OpenAPIOutput.route('openapi.json'),
    ui: Scalar(route: '/_docs'),
  ),
);
```

## Client Generation

```dart
void main() => defineSpryConfig(
  client: ClientConfig(
    pkgDir: '.spry/client',
    output: 'lib',
  ),
);
```
