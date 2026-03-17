# knex_dart Example

Spry with `knex_dart_sqlite` for a small SQLite-backed API.

Routes:

- `GET /`: describe the demo
- `GET /todos`: list todos
- `POST /todos`: create a todo with `{"title": "..."}` JSON
- `POST /todos/:id/toggle`: flip a todo between complete and incomplete

Run it like this:

```bash
cd example/knex_dart
dart pub get
dart run spry serve
```
