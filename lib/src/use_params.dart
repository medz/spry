import 'package:routingkit/routingkit.dart';

import '_constants.dart';
import 'types.dart';

Params useParams(Event event) {
  return switch (event.get(kParams)) {
    Params params => params,
    _ => const _EmptyParams(),
  };
}

class _EmptyParams implements Params {
  const _EmptyParams();

  @override
  String? get catchall => null;

  @override
  String? get(String name) => null;

  @override
  Iterable<String> get unnamed => const [];
}
