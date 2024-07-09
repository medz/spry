// ignore_for_file: file_names

import '../../constants.dart';
import '../locals/locals+get_or_null.dart';
import '../routing/route.dart';
import 'event.dart';

extension EventRoute on Event {
  /// Return [Route], when the route has not yet started matching
  /// or has not been matched to return null, usually this situation
  /// is when the route is registered and has entered the fallback processor.
  Route? get route => locals.getOrNull<Route>(kEventRoute);
}
