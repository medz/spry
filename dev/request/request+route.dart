// ignore_for_file: file_names

import 'dart:io';

import '../_internal/map+value_of.dart';
import '../routing/route.dart';
import 'request+locals.dart';

extension Request$Route on HttpRequest {
  /// Returns current request route.
  Route? get route => locals.valueOf(#spry.request.route, (_) => null);
}
