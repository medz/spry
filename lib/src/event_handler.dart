import 'dart:async';

import 'package:routingkit/routingkit.dart';

import 'event.dart';

typedef EventHandler<T> = FutureOr<T> Function(Event event);
typedef ResolvedEventHandler = MatchedRoute<EventHandler>;
