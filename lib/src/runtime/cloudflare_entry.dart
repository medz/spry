// ignore_for_file: implementation_imports

import 'package:osrv/osrv.dart' show Server;
import 'package:osrv/src/runtime/_internal/js/fetch_entry.dart' as internal;
import 'package:osrv/src/runtime/cloudflare/worker_js.dart' as cloudflare;

/// Defines the generated Cloudflare fetch entrypoint.
void defineCloudflareFetchEntry(Server server) {
  internal.defineFetchEntry(cloudflare.createCloudflareFetchEntry(server));
}
