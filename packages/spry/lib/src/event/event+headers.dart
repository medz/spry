// ignore_for_file: file_names

import '../http/headers/headers.dart';
import 'event.dart';

extension EventHeaders on Event {
  Headers get headers => request.headers;
}
