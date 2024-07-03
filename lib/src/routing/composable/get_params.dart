import 'package:routingkit/routingkit.dart' as routingkit show Params;

import '../../composable/get_context.dart';
import '../../event.dart';
import '../_routing_keys.dart';

typedef Params = routingkit.Params;

Params getRouteParams(Event event) {
  return getContext(event).upsert(kParams, () => Params());
}
