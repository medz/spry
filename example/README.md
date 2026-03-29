# Examples

Spry examples are organized by runnable scenario.

- `dart_vm/`: the canonical local example with routes, middleware, hooks, public assets, scoped middleware, and scoped error handling
- `openapi/`: a focused example that generates `public/openapi.json` with document `components` and route-level `globalComponents`
- `client_example/`: a focused client generation example with a paired `server/` app and generated `client/` package, documented in [client_example/README.md](/Users/seven/workspace/spry/example/client_example/README.md)
- `node/`: the smallest Node.js target example
- `bun/`: the smallest Bun target example
- `deno/`: the smallest Deno target example
- `cloudflare/`: the smallest Cloudflare Workers target example
- `vercel/`: the smallest Vercel target example
- `netlify/`: the smallest Netlify Functions target example
- `knex_dart/`: Spry with `knex_dart_sqlite` for a simple SQLite-backed API

Run any example like this:

```bash
cd example/<name>
dart pub get
dart run spry serve
```

Or build it explicitly:

```bash
cd example/<name>
dart pub get
dart run spry build
```
