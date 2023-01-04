import 'dart:async';

import 'context.dart';
import 'handler.dart';

/// Middleware next function type.
typedef Next = FutureOr<void> Function();

/// Middleware next function type.
@Deprecated('Use Next instead, this will be removed in 0.2 release.')
typedef MiddlewareNext = Next;

/// A function which creates a new [Handler] by wrapping a [Handler].
///
/// This is used to create a new [Handler] by wrapping an existing [Handler].
typedef Middleware = FutureOr<void> Function(Context context, Next next);
