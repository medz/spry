import 'dart:async';

import 'package:oxy/oxy.dart';

import 'platform.dart' if (dart.library.js_interop) 'platform.js.dart' as inner;
import 'request.dart';

/// A function type that handles server requests and returns responses.
///
/// The [ServerHandler] is a callback that processes incoming [ServerRequest] objects
/// and returns a [FutureOr<Response>]. The generic type parameter [Platform]
/// represents the platform-specific context available to the request.
typedef ServerHandler<Platform extends inner.Platform> =
    FutureOr<Response> Function(ServerRequest<Platform> request);
