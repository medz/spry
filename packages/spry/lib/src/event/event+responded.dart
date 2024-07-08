// ignore_for_file: file_names

import '../locals/locals+get_or_null.dart';
import 'event.dart';

const _key = #spry.event.response.responded;

extension EventResponded on Event {
  bool get responded => locals.getOrNull<bool>(_key) == true;

  set responded(bool status) {
    locals.set(_key, status);
  }
}
