import 'dart:async';

import 'package:oxy/oxy.dart';

import 'locals.dart';
import 'platform.dart' if (dart.library.js_interop) 'platform.js.dart' as inner;

abstract interface class ServerRequest<Platform extends inner.Platform>
    implements Request {
  /// Provides access to request-local storage.
  ///
  /// The [locals] object can be used to store and retrieve data that is specific
  /// to the current request and should not persist beyond its lifetime.
  ServerLocals get locals;

  /// Provides access to platform-specific context and functionality.
  ///
  /// The type [Platform] represents the specific platform implementation details
  /// that are available to this request.
  Platform get platform;

  /// IP address of the client.
  String? get ip;

  /// Tell the runtime about an ongoing operation that shouldn't close until the [Future] resolves.
  ///
  /// Example:
  /// ```dart
  /// serve(
  ///   fetch: (request) {
  ///     request.waitUntil(log(request));
  ///     return Response(body: Body.text("OK"));
  ///   }
  /// );
  /// ```
  void waitUntil<T>(FutureOr<T> future);
}
