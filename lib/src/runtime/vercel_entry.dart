// ignore_for_file: implementation_imports

import 'package:osrv/osrv.dart' show Server;
import 'package:osrv/src/runtime/_internal/js/fetch_entry.dart' as internal;
import 'package:osrv/src/runtime/vercel/fetch_js.dart' as vercel;

/// Defines the generated Vercel fetch entrypoint.
void defineVercelFetchEntry(Server server) {
  internal.defineFetchEntry(vercel.createVercelFetchEntry(server));
}
