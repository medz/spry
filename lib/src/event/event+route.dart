// ignore_for_file: file_names

import '../locals/locals+get_or_null.dart';
import '../routing/route.dart';
import 'event.dart';

extension EventRoute on Event {
  Route? get route => locals.getOrNull<Route>(Route);
}
