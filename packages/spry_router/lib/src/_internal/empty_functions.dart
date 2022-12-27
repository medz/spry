import 'dart:async';

import 'package:spry/spry.dart';

FutureOr<void> emptyMiddleware(Context context, MiddlewareNext next) => next();
