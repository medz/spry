// ignore_for_file: file_names

import '../_internal/map+value_of.dart';
import '../application.dart';
import 'exceptions.dart';

extension Application$Exceptions on Application {
  /// Returns spry application exceptions.
  Exceptions get exceptions {
    return locals.valueOf(#spry.exceptions, (_) {
      return locals[#spry.exceptions] = Exceptions();
    });
  }
}
