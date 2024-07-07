// ignore_for_file: file_names

import 'dart:async';

import 'event/event.dart';
import 'handler/_closure_handler.dart';
import 'utils/_spry_internal_utils.dart';
import 'spry.dart';

extension SpryHandler on Spry {
  void use<T>(FutureOr<T> Function(Event event) closure) {
    addHandler(ClosureHandler<T>(closure));
  }
}
