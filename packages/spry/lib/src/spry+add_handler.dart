// ignore_for_file: file_names

import 'handler/handler.dart';
import 'spry.dart';
import 'utils/_spry_internal_utils.dart';

extension SpryAddHandler on Spry {
  /// Adds a handler.
  void addHandler(Handler handler) => handlers.add(handler);
}
