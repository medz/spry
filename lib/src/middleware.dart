import 'dart:async';

import 'context.dart';
import 'handler.dart';

typedef MiddlewareNext = FutureOr<void> Function();

/// A function which creates a new [Handler] by wrapping a [Handler].
///
/// This is used to create a new [Handler] by wrapping an existing [Handler].
typedef Middleware = FutureOr<void> Function(
    Context context, MiddlewareNext next);
