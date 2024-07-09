// ignore_for_file: file_names

import '../../constants.dart';
import '../locals/locals+get_or_set.dart';
import '../types.dart';
import 'event.dart';

extension EventParams on Event {
  Params get params {
    return locals.getOrSet<Params>(kEventParams, Params.new);
  }
}
