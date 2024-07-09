// ignore_for_file: file_names

import 'dart:async';

import 'event/event.dart';
import 'handler/closure_handler.dart';
import 'spry.dart';
import 'spry+add_handler.dart';

extension SpryHandler on Spry {
  /// Adds a closure handler.
  void use<T>(FutureOr<T> Function(Event event) closure) {
    addHandler(ClosureHandler<T>(closure));
  }
}
