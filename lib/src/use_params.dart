import 'package:routingkit/routingkit.dart';

import '_constants.dart';
import 'types.dart';

/// Returns the request [Event] matched route params.
Params useParams(Event event) {
  return switch (event.get(kParams)) {
    Params params => params,
    _ => const <String, String>{} as Params,
  };
}
