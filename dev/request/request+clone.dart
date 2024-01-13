// ignore_for_file: file_names

import 'dart:io';

import '../_internal/request.dart';
import '../_internal/request+clone.dart';

extension Request$Clone on HttpRequest {
  HttpRequest clone() => SpryRequest.of(this).innerClone();
}
