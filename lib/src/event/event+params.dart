// ignore_for_file: file_names

import '../locals/_locals+get_or_set.dart';
import '../types.dart';
import 'event.dart';

extension EventParams on Event {
  Params get params {
    return locals.getOrSet<Params>(Params, Params.new);
  }
}
