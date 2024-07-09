// ignore_for_file: file_names

import '../../constants.dart';
import '../platform/platform.dart';
import 'event.dart';

extension EventGetClientAddress on Event {
  String getClientAddress() {
    final raw = locals.get(kRawRequest);
    final platform = locals.get<Platform>(kPlatform);

    return platform.getClientAddress(this, raw);
  }
}
