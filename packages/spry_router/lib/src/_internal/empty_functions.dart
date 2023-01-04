import 'dart:async';

import 'package:spry/spry.dart';

FutureOr<void> emptyMiddleware(Context context, Next next) => next();
