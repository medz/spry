# Spry Routing Reference

Each route file exports `handler`, a `FutureOr<Response> Function(Event)`. Method suffixes restrict requests; without a suffix the handler accepts any method.

| File | Generated pattern | Behavior |
|---|---|---|
| `routes/index.dart` | `/` | Root path |
| `routes/users.get.dart` | `/users` | GET only; HEAD falls back to GET |
| `routes/users/[id].dart` | `/users/:id` | One captured segment |
| `routes/posts/[id([0-9]+)].dart` | `/posts/:id([0-9]+)` | Numeric IDs |
| `routes/files/[name].[ext].dart` | `/files/:name.:ext` | Embedded captures |
| `routes/docs/[[section]].dart` | `/docs/:section?` | Optional segment |
| `routes/assets/[...path+].dart` | `/assets/:path+` | One or more segments |
| `routes/archive/[[...rest]].dart` | `/archive/:rest*` | Zero or more segments |
| `routes/users/[_].dart` | `/users/*` | Exactly one segment |
| `routes/files/[...catchall].dart` | `/files/**:catchall` | Named remainder wildcard |

```dart
// routes/users/[id].get.dart
import 'package:spry/spry.dart';

Response handler(Event event) => Response.json({'user': event.params['id']});
```

Supported method suffixes are `.get`, `.post`, `.put`, `.delete`, `.patch`, `.head`, and `.options`. An explicit HEAD handler wins; an any-method handler also takes precedence over GET fallback.

An unsuffixed root remainder file, such as `routes/[...].dart` or `routes/[...catchall].dart`, defines the app fallback. It exports `handler` and receives no matched-route params, including for the named form. `routes/index.dart` handles `/` only. Named remainder routes below a path prefix, such as `routes/files/[...catchall].dart`, use the normal router and capture their named params.

Matching is case-sensitive by default. Set `caseSensitive: false` in `spry.config.dart` to ignore case. The router selects the most specific eligible match. Scoped middleware and error handlers use generated remainder patterns such as `/users/:id/**`.
