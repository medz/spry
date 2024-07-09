// ignore_for_file: file_names

import 'event.dart';

extension EventMethod on Event {
  /// Access to the normalized (uppercase) request method.
  String get method => request.method.toUpperCase().trim();
}
