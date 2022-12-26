import 'dart:async';

import 'context.dart';

typedef Handler = FutureOr<void> Function(Context context);
