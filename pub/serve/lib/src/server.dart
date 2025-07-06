import 'dart:async';

import 'package:oxy/oxy.dart';

import 'platform.dart' if (dart.library.js_interop) 'platform.js.dart' as inner;

abstract interface class Server<Platform extends inner.Platform> {
  Platform get platform;

  /// Server listen URL address.
  String? get url;

  /// Returns a [Future] that resolves when the server is ready.
  Future<Server<Platform>> ready();

  /// Stop listening to prevent new connections from being accepted.
  ///
  /// By default, the server will wait for all ongoing operations to complete before shutting down.
  /// If [force] is set to `true`, the server will immediately shut down without waiting for ongoing operations.
  Future<void> close([bool force = false]);

  /// Server fetch handler.
  Future<Response> fetch(Request request);
}
