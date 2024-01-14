// ignore_for_file: file_names

import 'dart:io';

import '../_internal/response.dart';

extension Response$IsClosed on HttpResponse {
  bool get isClosed => (this as SpryResponse).isClosed;
}
