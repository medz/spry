import 'dart:async';

import 'context.dart';

/// Spry framwork handler.
typedef Handler = FutureOr<void> Function(Context context);
