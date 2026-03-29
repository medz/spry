# Spry Client Example

This example demonstrates two things at the same time:

- how a Spry app in `server/` declares route metadata and route-level OpenAPI metadata
- what the generated client in `client/` currently looks like

Directory layout:

- [server](/Users/seven/workspace/spry/example/client_example/server)
  The Spry server example. Its `spry.config.dart` writes client output to `../client`.
- [client](/Users/seven/workspace/spry/example/client_example/client)
  The output directory for `spry build client`. It also keeps a minimal `main.dart` for local debugging.

Entry points:

- Server config entry: [server/spry.config.dart](/Users/seven/workspace/spry/example/client_example/server/spry.config.dart)
- Generated client entry: [client/lib/client.dart](/Users/seven/workspace/spry/example/client_example/client/lib/client.dart)
- Client debug entry: [client/main.dart](/Users/seven/workspace/spry/example/client_example/client/main.dart)

## Generate the client

Start in the server directory:

```bash
cd /Users/seven/workspace/spry/example/client_example/server
dart pub get
dart run spry build client
```

Generated output will appear in:

- [client/lib/client.dart](/Users/seven/workspace/spry/example/client_example/client/lib/client.dart)
- [client/lib/routes.dart](/Users/seven/workspace/spry/example/client_example/client/lib/routes.dart)
- [client/lib/params.dart](/Users/seven/workspace/spry/example/client_example/client/lib/params.dart)
- [client/lib/inputs.dart](/Users/seven/workspace/spry/example/client_example/client/lib/inputs.dart)
- [client/lib/headers.dart](/Users/seven/workspace/spry/example/client_example/client/lib/headers.dart)
- [client/lib/queries.dart](/Users/seven/workspace/spry/example/client_example/client/lib/queries.dart)
- [client/lib/outputs.dart](/Users/seven/workspace/spry/example/client_example/client/lib/outputs.dart)
- [client/lib/models.dart](/Users/seven/workspace/spry/example/client_example/client/lib/models.dart)

## What this example covers

The server routes currently cover:

- basic static and dynamic routes
- deeply nested routes
- regex, optional, repeated, remainder, and embedded segments
- route-level OpenAPI request bodies
- route-level OpenAPI query parameters
- route-level OpenAPI header parameters
- route-level `globalComponents`

The generated client currently demonstrates:

- `*Routes`
- `*Params`
- `*Input`
- `*Headers`
- `*Query`
- `*Output`
- `models/*`
- request construction inside `call(...)`
- `oxy.send(...)` inside `call(...)`
- typed output decoding for single successful JSON responses

## Quick entry files

If you want to inspect the current generation semantics quickly, start with:

- [server/routes/index.get.dart](/Users/seven/workspace/spry/example/client_example/server/routes/index.get.dart)
- [server/routes/users/index.post.dart](/Users/seven/workspace/spry/example/client_example/server/routes/users/index.post.dart)
- [server/routes/users/[id].get.dart](/Users/seven/workspace/spry/example/client_example/server/routes/users/%5Bid%5D.get.dart)
- [server/routes/search/index.get.dart](/Users/seven/workspace/spry/example/client_example/server/routes/search/index.get.dart)
- [server/routes/profile/index.get.dart](/Users/seven/workspace/spry/example/client_example/server/routes/profile/index.get.dart)
- [server/shared/input_specs.dart](/Users/seven/workspace/spry/example/client_example/server/shared/input_specs.dart)

The matching generated client files are:

- [client/lib/routes/index.dart](/Users/seven/workspace/spry/example/client_example/client/lib/routes/index.dart)
- [client/lib/routes/users/index.dart](/Users/seven/workspace/spry/example/client_example/client/lib/routes/users/index.dart)
- [client/lib/routes/users/[id].dart](/Users/seven/workspace/spry/example/client_example/client/lib/routes/users/%5Bid%5D.dart)
- [client/lib/queries/search/index.get.dart](/Users/seven/workspace/spry/example/client_example/client/lib/queries/search/index.get.dart)
- [client/lib/headers/profile/index.get.dart](/Users/seven/workspace/spry/example/client_example/client/lib/headers/profile/index.get.dart)
- [client/lib/outputs/index.get.dart](/Users/seven/workspace/spry/example/client_example/client/lib/outputs/index.get.dart)
- [client/lib/outputs/users/index.post.dart](/Users/seven/workspace/spry/example/client_example/client/lib/outputs/users/index.post.dart)
- [client/lib/models/address.dart](/Users/seven/workspace/spry/example/client_example/client/lib/models/address.dart)
- [client/lib/models/participant.dart](/Users/seven/workspace/spry/example/client_example/client/lib/models/participant.dart)

## Run the client debug entry

The client directory currently includes a minimal debug entry:

- [client/main.dart](/Users/seven/workspace/spry/example/client_example/client/main.dart)

You can run it directly:

```bash
cd /Users/seven/workspace/spry/example/client_example/client
dart pub get
dart run main.dart
```

This entry exists only to make local client API validation easier during development. It is not meant to represent the final recommended integration style.
