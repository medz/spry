// ignore_for_file: file_names

import '../http/headers.dart';
import 'event.dart';

extension EventHeaders on Event {
  /// Access to the normalized request [Headers].
  Headers get headers => request.headers;
}
