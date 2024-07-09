// ignore_for_file: file_names

import '../../constants.dart';
import '../platform/platform.dart';
import 'event.dart';

extension EventGetClientAddress on Event {
  /// Returns client address.
  ///
  /// Value formated of `<ip>:port`.
  ///
  /// The returned value comes from the Platform implementation.
  /// If the platform does not support it, an empty string will be returned.
  String getClientAddress() {
    final raw = locals.get(kRawRequest);
    final platform = locals.get<Platform>(kPlatform);

    return platform.getClientAddress(this, raw);
  }
}
