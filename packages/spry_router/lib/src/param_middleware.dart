import 'dart:async';

import 'package:spry/spry.dart';

/// Param Middleware next function.
typedef ParamMiddlewareNext = FutureOr<void> Function(Object? value);

/// Param middleware.
typedef ParamMiddleware = FutureOr<void> Function(
    Context context, Object? value, ParamMiddlewareNext next);
