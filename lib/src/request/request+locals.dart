// ignore_for_file: file_names

import 'dart:io';

import '../_internal/request.dart';

extension Request$Locals on HttpRequest {
  /// The local storage for this request.
  Map get locals => SpryRequest.of(this).locals;
}
