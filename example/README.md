# Examples

Minimal file-routing example with:

- `routes/`
- global middleware
- scoped middleware
- scoped error handling
- `hooks.dart`

Run it like this:

```bash
cd example
dart pub get
dart run spry build
dart run .spry/main.dart
```

Or use the CLI serve command:

```bash
cd example
dart pub get
dart run spry serve
```

Alternative runtime configs:

```bash
dart run spry build --config cloudflare.config.dart
dart run spry serve --config vercel.config.dart
```
