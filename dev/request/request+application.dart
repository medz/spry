// ignore_for_file: file_names

import 'dart:io';

import '../_internal/request.dart';
import '../application.dart';

extension Request$Application on HttpRequest {
  /// The [Application] instance that is handling this request.
  Application get application => SpryRequest.of(this).application;
}
