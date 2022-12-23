import 'dart:io';

import 'body.dart';

abstract class Request {
  /// Read the request body.
  Body get body;

  /// Get the request headers.
  HttpHeaders get headers;

  /// Get the request method.
  String get method;
}
