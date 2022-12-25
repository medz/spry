import 'dart:convert';
import 'dart:io';

import '../response.dart';

class ResponseImpl extends Response {
  /// [HttpResponse] instance.
  final HttpResponse response;

  @override
  final List<Cookie> cookies = [];

  @override
  HttpHeaders get headers => response.headers;

  @override
  Encoding encoding = utf8;

  /// Creates a new [ResponseImpl] instance.
  ResponseImpl(this.response);
}
