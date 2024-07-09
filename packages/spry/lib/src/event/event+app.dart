// ignore_for_file: file_names

import '../../constants.dart';
import '../spry.dart';
import 'event.dart';

extension EventApp on Event {
  /// Returns the [Spry] instance for the request event.
  Spry get app => locals.get<Spry>(kAppInstance);
}
