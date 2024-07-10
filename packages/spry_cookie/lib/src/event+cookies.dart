// ignore_for_file: file_names

import 'package:spry/spry.dart';

import '_internal.dart';
import 'cookies.dart';

extension EventCookies on Event {
  /// Returns the [Cookies] for the current [Event].
  Cookies get cookies {
    final instance = locals.getOrNull<Cookies>(kCookiesInstance);
    if (instance == null) {
      throw Exception(
          'Cookies are not enabled. Please enable using `app.use(cookie())`');
    }

    return instance;
  }
}
