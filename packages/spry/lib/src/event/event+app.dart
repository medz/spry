// ignore_for_file: file_names

import '../spry.dart';
import 'event.dart';

extension EventApp on Event {
  Spry get app => locals.get(Spry);
}
