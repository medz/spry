// ignore_for_file: file_names

import 'event.dart';

extension EventURI on Event {
  Uri get uri => request.uri;
}
