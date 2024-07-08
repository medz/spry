// ignore_for_file: file_names

import 'event.dart';

extension EventMethod on Event {
  String get method => request.method;
}
